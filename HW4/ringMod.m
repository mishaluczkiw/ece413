function [output] = ringMod(input, freq, depth, Fs)

% This function performs ring modulation

len = size(input,1);
t = 0:1/Fs:len/Fs;
t = t(1:len);
% need to know the sampling frequency Fs to create sinusoid


sinusoid = depth*sin(2*pi*freq*t);

output = zeros(len,1);

for i = 1:len % when I try elementwise multiplication 
              % I get "Out of memory" error

    output(i) = input(i,1)+input(i,1).*sinusoid(i);
end




end