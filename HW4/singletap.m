function [y] = singletap(x,FF,delay,FB,Fs)

% Function performs delay basedo o
% http://users.cs.cf.ac.uk/Dave.Marshall/CM0268/PDF/10_CM0268_Audio_FX.pdf
%BL=0.5;
BL = 1;   % BLEND
%FB=-0.5; % FEEDBACK
%FF=1;    % DEPTH/FEEDFORWARD

M = ceil((delay*Fs)/1000); % DELAY IN SAMPLES

Delayline=zeros(M,1); % memory allocation for length M
for n=1:length(x);
  xh=x(n)+FB*Delayline(M); % DELAY MIX
  y(n)=FF*Delayline(M)+BL*xh; 
  Delayline=[xh;Delayline(1:M-1)];
end




end