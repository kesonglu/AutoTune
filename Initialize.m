function Initialize

% Initializing
global min_freq max_freq peak_threshold max_autocorrelation_threshold max_harmonic_deviation max_prediction_deviation;
global block_length block_steps block_size step_size Fs prediction_samples;


min_freq = 80;
max_freq = 1100;
peak_threshold = 0.25;
block_length = 0.08;
block_steps = 4;
max_autocorrelation_threshold = 0.5;
max_harmonic_deviation = 0.4;
max_prediction_deviation = 0.3;

%block_size =  block_steps*round( block_length*Fs/ block_steps);
%step_size =  block_size /  block_steps;

block_size = 1024;
step_size = 128;

prediction_sample_time = 0.08;
prediction_samples = floor(prediction_sample_time*Fs/step_size);


global CircleBuf CorrectedDate gains1 gains2 delays1 delays2;
global ph1 ph2 pstep ovrlp sd  fgain pWrite1 CircleLen ;



%Overlap
Overlap = 0.5;
%Delays
pMaxDelay = 0.03;       % 30ms
pSampsDelay = round(pMaxDelay * Fs);
%Pitch rate
%semi-tones
pRate = (1 - 0)/pMaxDelay;
%Phase step
pPhaseStep = pRate / Fs;
Phase2State = (1 - Overlap);
%Cross-fading gain
pFaderGain = 1/Overlap;
%% Operation
blockSize = step_size;
CircleLen = pSampsDelay;
CircleBuf = zeros(1,CircleLen);
CorrectedDate = zeros(blockSize,1);

gains1 = zeros(blockSize,1);
gains2 = zeros(blockSize,1);

delays1 = zeros(blockSize,1);
delays2 = zeros(blockSize,1);

ph1   = 0;
ph2   = Phase2State;
pstep = pPhaseStep;
ovrlp = Overlap;
sd    = pSampsDelay;
fgain = pFaderGain;

pWrite1 = 1;

end