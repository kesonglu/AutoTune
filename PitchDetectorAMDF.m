function freq = PitchDetectorAMDF(BlockDate)
global min_freq max_freq block_size;
global Fs ;
min_shift = floor(Fs / max_freq);
max_shift = ceil(Fs / min_freq);
R0 = zeros(block_size,1); 
R = zeros(block_size,1);
u = BlockDate;
wlen = block_size;
for m = 1:block_size
    R0(m) = sum(abs(u(m:wlen)-u(1:wlen-m+1)));  % 计算平均幅度差函数
end
[Rmax,Nmax]=max(R0);                            % 求取AMDF中最大值和对应位置
for i = 1 : block_size                          % 进行线性变换
    R(i)=Rmax*(wlen-i)/(wlen-Nmax)-R0(i);
end
[Rmax,T]=max(R(min_shift:max_shift));           % 求出最大值
T0=T+min_shift-1;
period = T0;
freq = 1/period*Fs;
end