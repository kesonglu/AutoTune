function Ratio=PitchScale(freq, tonic_str, scale_str)

all_notes = [82.41 87.31 92.50 98.00 103.83 110.00 116.54 123.47 130.81 138.59 146.83 155.56 ...
    164.81 174.61 185.00 196.00 207.65 220.00 233.08 246.94 261.63 277.18 293.66 311.13 ...
    329.63 349.23 369.99 392.00 415.30 440.00 466.16 493.88 523.25 554.37 587.33 622.25 ...
    659.26 698.46 739.99 783.99 830.61 880.00 932.33 987.77 1046.50];
major = [2, 2, 1, 2, 2, 2, 1];
minor = [2, 1, 2, 2, 1, 2, 2];
chromatic = 1;
E = 1;
F = 2;
Fs = 3;
G = 4;
Gs = 5;
A = 6;
As = 7;
B = 8;
C = 9;
Cs = 10;
D = 11;
Ds = 12;

tonic =  E;
scale =  chromatic;

switch lower(tonic_str)
    case 'e'
        tonic =  E;
    case 'f'
        tonic =  F;
    case 'fs'
        tonic =  Fs;
    case 'g'
        tonic =  G;
    case 'gs'
        tonic =  Gs;
    case 'a'
        tonic =  A;
    case 'as'
        tonic =  As;
    case 'b'
        tonic =  B;
    case 'c'
        tonic =  C;
    case 'cs'
        tonic =  Cs;
    case 'd'
        tonic =  D;
    case 'ds'
        tonic =  Ds;
end

switch lower(scale_str)
    case 'major'
        scale =  major;
    case 'minor'
        scale =  minor;
    case 'chrom'
        scale =  chromatic;
    case 'chromatic'
        scale =  chromatic;
end

note_index = tonic;
scale_type = scale;
scale_index = 1;
notes = 1:length(all_notes);

i = 0;
while note_index <= length(all_notes)
    i = i + 1;
    notes(i) = all_notes(note_index);
    note_index = note_index + scale_type(scale_index);
    if scale_index >= length(scale_type)
        scale_index = 1;
    else
        scale_index = scale_index + 1;
    end
end
notes = notes(1:i);

freq_orig = freq;

for n = 1:1
    if freq_orig < 50
        freq_new = 0;
    else
        diff = abs(notes - freq_orig);
        [~, I] = min(diff);
        freq_new = notes(I);
    end
end
if freq_orig==0
    Ratio = 1;
else
    Ratio = freq_new/freq_orig;
end
end