% MPEG LAYER I IMPLEMENTATION 
% Misha Luczkiw
% April 30, 2019
% Music and Engineering, Prof. Tim Hoerning


clear all; close all; clc



[rec Fs] = audioread('riff.wav');

bufferLength = 32;      % 
sampleIncr = 32; 
%%
%%%%%%%%%%%%%%%%%%%% Frequency Domain Encoding %%%%%%%%%%%%%%%%%%%%%%%%%%%

X_FIFO = zeros(1,512);


Z = zeros(1,512); % Z vector, window of recording
Y = zeros(1,64);     % Y vector, sum of Z vector into 64 samples
S = zeros(1,32);     % Si matrix coefficients for 
M = zeros(32,64);    % M matrix 

% for performing MDCT
for i = 0:31
    for k = 0:63
        M(i+1,k+1) = cos((2*i + 1)*(k - 16)*pi/64);
    end
end

N = zeros(64,32);
% for performing IMDCT
for i = 0:63
    for k = 0:31
        N(i+1,k+1) = cos((16 + i)*(2*k + 1)*pi/64);
        
    end
end
    
    
V = zeros(1,64);
U = zeros(1,512);
V_FIFO = zeros(1,1024);
W = zeros(1,512);
out = zeros(1,32);

reconstructed = zeros(1,size(rec,1));

C = importdata('C.mat'); % stores the window coefficients for analysis
D = importdata('D.mat'); % stores the window coefficients for synthesis

numBuffers = floor((length(rec)-bufferLength)/sampleIncr)+1;

% fill buffer
for ii = 1:numBuffers  % for each buffer
    % X_FIFO
    %     ...........................................................
    %     |  32 samples   |       |         480 samples        
    %     n              n+31    n-480                         
    % left most bit is the newest bit
    X_FIFO = [fliplr(rec(32*(ii-1)+1:32*(ii-1)+32)) X_FIFO(1:end-32)];
    Z = X_FIFO.*C;
    %Z = rec(32*(ii-1)+1:32*(ii-1)+512).*C;
    Y = sum(reshape(Z,[64 8]),2)';
    
    % perform MDCT
    S = M*Y';
 
    % to be done... all the analysis
    
    
    % perform IMDCT
    V = N*S;
    
    % append to FIFO
    V_FIFO = [V' V_FIFO(1:end-64)]; % get rid of last values
    %V_FIFO = [V_FIFO(1:end-64) V'];
    
    % Build U vector
    for i = 0:7
        for j = 0:31
            U(i*64+j+1) = V_FIFO(i*128+j+1); %plus one because of MATLAB indexing
            U(i*64+32+j+1) = V_FIFO(i*128+96+j+1);
        end
    end
    
    W = U.*D;
    
    out = sum(reshape(W,[32 16]),2)';
   
    reconstructed(32*(ii-1)+1:32*(ii-1)+32) = out;
    
   
    
end    

%soundsc(rec,Fs)
soundsc(reconstructed,Fs)
