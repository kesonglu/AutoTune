function [freq,target_freq]=PitchDetector(BlockDate,target_freq)
global min_freq max_freq peak_threshold max_autocorrelation_threshold max_harmonic_deviation max_prediction_deviation;
global Fs ;
min_shift = floor(Fs / max_freq);
max_shift = ceil(Fs / min_freq);
all_shifts = min_shift:max_shift;
shifts_in_time = all_shifts / Fs;

wave_chunk = BlockDate(1:max_shift);
normalize_factor = max(BlockDate);

% Autocorrelation by hand
autocorrelation = zeros(1, length(all_shifts));
i = 1;
for n = all_shifts
    % If shifting beyond length of block, break
    if max_shift + n > length(BlockDate)
        all_shifts = all_shifts(1:i-1);
        shifts_in_time = shifts_in_time(1:i-1);
        autocorrelation = autocorrelation(1:i-1);
        break
    end
    autocorrelation(i) = 1 - sum(abs(wave_chunk - BlockDate((1:max_shift) + n)))/normalize_factor;
    i = i + 1;
end
autocorrelation = autocorrelation - min(autocorrelation);

[max_coordinates, max_coordinate_neighbors, max_heights, max_height_neighbors] = find_maxima(shifts_in_time, autocorrelation, 1/max_freq);

% Cut down possibilities for max_index over time
max_indexes = 1:length(max_coordinates);

% Keep heights above peak_threshold
max_indexes = max_indexes(max_heights > max_autocorrelation_threshold*max(max_heights) & max_heights > peak_threshold);
max_coordinates = max_coordinates(max_indexes);

% Sort
[max_coordinates, I] = sort(max_coordinates);
max_indexes = max_indexes(I);

% Keep harmonics within max_harmonic deviation
N = length(max_indexes);
possible_freqs = zeros(1,N);
freq = 0;
for n = 1:N-1
    if any(abs(1 - max_coordinates(n+1:N)./(2*max_coordinates(n))) < max_harmonic_deviation)
         if isempty(target_freq)
            freq = 1 / max_coordinates(n);
            max_indexes = max_indexes(n);
            break
         else
             possible_freqs(n) = 1 / max_coordinates(n);
         end
    end
end

% Find the closest harmonic match
if ~isempty(target_freq)
    freq_error = abs(possible_freqs./target_freq - 1);
    [value, index] = min(freq_error);
    if value < max_prediction_deviation
        freq = possible_freqs(index);
        max_indexes = max_indexes(index);
    end
end     
end


function EchoData = echo(data,Fs)
wave = data;
delay = Fs*0.4;
decay = 0.1;

wave = [wave zeros(1, delay)];
echo1 = zeros(1, length(wave));

for n = 1:delay
    echo1(n) = wave(n);
end
for n = delay+1:length(wave)
    echo1(n) = wave(n) + decay * wave(n - delay);
end

EchoData = echo1;
end
function [max_coordinates, max_coordinate_neighbors, max_heights, max_height_neighbors] = find_maxima(coordinates, heights, min_time_delta)
% Get maxima
heights_d = diff(heights);
no_zeros = find(heights_d(1:end-1) > 0 & heights_d(2:end) < 0);
one_zero = find(heights_d(1:end-2) > 0 & heights_d(2:end-1) == 0 & heights_d(3:end) < 0);
two_zeros = find(heights_d(1:end-3) > 0 & heights_d(2:end-2) == 0 & heights_d(3:end-1) == 0 & heights_d(4:end) < 0);
three_zeros = find(heights_d(1:end-4) > 0 & heights_d(2:end-3) == 0 & heights_d(3:end-2) == 0 & heights_d(4:end-1) == 0 & heights_d(5:end) < 0);

% Store indexes
max_indexes = [(no_zeros + 1) (one_zero + 1) (two_zeros + 2) (three_zeros + 3)];
max_coordinates = coordinates(max_indexes);
max_heights = heights(max_indexes);

% Sort
[max_heights, indexes] = sort(max_heights, 'descend');
max_coordinates = max_coordinates(indexes);
max_indexes = max_indexes(indexes);

% Filter out peaks within min_time_delta
indexes_to_remove = zeros(1, length(max_coordinates));
i = 1;
for n = 1:(length(max_coordinates) - 1)
    if abs(max_coordinates(n) - max_coordinates(n+1)) < min_time_delta
        max_coordinates(n) = max_coordinates(n+1);
        max_heights(n) = max_heights(n+1);
        indexes_to_remove(i) = n;
        i = i + 1;
    end
end
indexes_to_remove = indexes_to_remove(1:i-1);
max_coordinates(indexes_to_remove) = [];
max_heights(indexes_to_remove) = [];
max_indexes(indexes_to_remove) = [];

% Get the neighbors of peaks
max_coordinate_neighbors = zeros(length(max_indexes),5);
max_height_neighbors = zeros(length(max_indexes),5);
for n = 1:length(max_indexes)
    if max_indexes(n) > 3 && max_indexes(n) < length(coordinates)-2
        i = max_indexes(n) + (-2:2);
        max_coordinate_neighbors(n,1:5) = coordinates(i);
        max_height_neighbors(n,1:5) = heights(i);
    end
end
end
