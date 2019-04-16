function [output] = distortion(x,a,tone)

% This function performs foldback distortion on the audio signal x


% a is gain: can take a value between -1 and 1
% implementation of algorithm based off of wwww.musicdsp.org
% https://www.mathworks.com/matlabcentral/fileexchange/6639-guitar-distortion-effect
% it sounds good 


k = 2*a/(1-a);
output = (1+k)*(x)./(1+k*abs(x));

r = 0.5;
theta = pi/4;
a1 = -2*r*cos(theta);
a2 = r^2;

% tone = 0 should be low pass
% tone = 1 should be high pass

tone = -((tone*2)-1)
output = filter([1,tone],[1 a1 a2],output);





end