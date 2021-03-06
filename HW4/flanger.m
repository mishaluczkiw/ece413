function [y] = flanger(x,depth,min_delay,sweepDepth,rate,Fs)

% Function performs flanging via single FIR delay
% Based off of implementation on:
% http://users.cs.cf.ac.uk/Dave.Marshall/CM0268/PDF/10_CM0268_Audio_FX.pdf
%BL=0.5;
BL = 1;   % BLEND
%FB=-0.5; % FEEDBACK
%FF=1;    % DEPTH/FEEDFORWARD

len = size(x,1);
index = 1:len;

% calculate maximum delay, which will affect amplitude of LFO
max_delay = min_delay+sweepDepth; % all in milliseconds


% set sin reference of LFO
sin_ref = sin(2*pi*rate*index*(rate/Fs));
%sin_ref = sawtooth(2*pi*rate*index*(rate/Fs),0.5); uncomment for triangle wave

% center sin_ref to vary from min_delay to max_delay
sin_ref = (sin_ref+1)/2;                 % 0 - 1
sin_ref = sin_ref*(max_delay-min_delay); % 0 - max_delay-min_delay
sin_ref = sin_ref+min_delay;             % min_delay-max_delay

max_samp_delay=round(max_delay/1000*Fs);

% avoid referencing negative indexes
y(1:max_samp_delay)=x(1:max_samp_delay);



% for each sample
for i = (max_samp_delay+1):size(x,1)
  cur_sin=sin_ref(i);    
  % generate delay from 1-max_samp_delay and ensure whole number
  cur_delay=ceil(cur_sin);
  % add delayed sample
  y(i) = x(i) + depth*(x(i-cur_delay));
end




end