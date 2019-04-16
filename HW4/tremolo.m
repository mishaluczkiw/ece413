function [output] = tremolo(input,type,rate,lag,depth,Fs)
% this function performs stereo tremolo

len = size(input,1);
t = 0:1/Fs:(len/Fs)+lag/1000;
%t = t(1:len);

% depth controls the minimum of the envelope
% 1 means full scale
% 0 means clean

% lag?



switch type
    case 'sin'
        envelope = sin(2*pi*rate*t);
    case 'triangle'
        envelope = sawtooth(2*pi*rate*t,0.5);
    case 'square'
        envelope = square(2*pi*rate*t);
        
end

% make envelope go from 1 to (1-depth)

% first: make envelope go from 1 to -1 to 1 to 0
envelope = 2*envelope-1;
% second: make envelope go from 1 to (1-depth)
if depth ~= 1 % if depth == 1, leave as is
    envelope = envelope*(1-depth);
    envelope = envelope+(1-depth);
end


output = zeros(size(input));

% convert lag from milliseconds to correct increments in t vector
% 1: lag from milli to sec
lag = lag/1000;
% 2: multiply lag by sample rate and take floor
lag = floor(lag*Fs);

for i = 1:len
    output(i,1) = envelope(i)*input(i,1);
    
    if size(input,2) == 2 % if stereo sound
            output(i,2) = envelope(i+lag)*input(i,2);
        
    end
end




end