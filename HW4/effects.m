% HW4 Music and Engineering Effects
% Misha Luczkiw
% April 16, 2019

clc
close all
clear functions
clear variables
clear figures
dbstop if error

% read audio from Razorlight - 'In the Morning' (30 sec)
% 'Alesis-Fusion-Clean-Guitar-C3.wav'
% 'Korg-N1R-Harmonics-C5.wav'
% 'In_The_Morning.wav'
[y, Fs] = audioread('Chop_Suey.wav');
t = 0:1/Fs:length(y)/Fs;

%[y, Fs] = audioread('Korg-N1R-Harmonics-C5.wav');
%[y, Fs] = audioread('Alesis-Fusion-Clean-Guitar-C3.wav');


%% 1. Compressor
clear all
close all
[y, Fs] = audioread('Chop_Suey.wav');
t = 0:1/Fs:length(y)/Fs;

len = size(y,1);
t = t(1:len);
power_compressed = zeros(1,len);

threshold = 0.1; % in db (0 is the max a signal can have)
slope = 1;
avgLength = 10;


[compressed, gain,power] = compressor(y(:,1), threshold, slope, avgLength);

mask = power > threshold;


figure
subplot(1,3,1)
plot(t,y(:,1))
hold on
% plot where threshold exceeds
plot(t(mask),repmat(threshold,[1 length(t(mask))]),'r*')
title('original')
ylim([0 1])
xlabel('time in sec')
ylabel('ouput level')
legend('original','power exceeds threshold')
subplot(1,3,2)
plot(t,compressed)
title('compressed')
ylim([0 1])
subplot(1,3,3)
plot(t,gain)
title('gain')
ylim([0 1])
xlabel('time in sec')
ylabel('gain level')


% recalculate power for compressed signal to see if it exceeds the
% threshold


for i = 1:len
    
    % corner case at the beginning
    if i-avgLength < 1
        power_compressed(i) = sqrt(sum(compressed(i:i+avgLength).^2));
    
    else
    power_compressed(i) = sqrt(sum(compressed(i-avgLength:i).^2));
    end
end
power_compressed = power_compressed/avgLength;

figure
subplot(1,2,1)
plot(1:len,power)
title('power original')
ylim([0 1])
subplot(1,2,2)
plot(1:len,power_compressed)
title('power compressed')
ylim([0 1])

%sound(y,Fs);
%pause(t(end));
sound(compressed,Fs);
pause(t(end))

%% 2. Ring Modulator
clear all
%[C5, Fs] = audioread('Korg-N1R-Harmonics-C5.wav');
%[C5, Fs] = audioread('In_The_Morning.wav');
[C5, Fs] = audioread('Du_Hast.wav');
ring = ringMod(C5,100,1,Fs);

sound(ring,Fs)
pause(2);

%% 3. Stereo Tremolo
len = size(C5,1);
t = 0:1/Fs:len/Fs;

t = t(1:len);


trem = tremolo(C5,'sin',0.5,500,0.5,Fs);

%sound(C5,Fs);

sound(trem,Fs)
pause(t(end));

figure
subplot(1,2,1)
plot(t,C5)
title('original')
subplot(1,2,2)
plot(t,trem)
title('stereo tremolo')

%% 4. Distortion

clear all
[riff, Fs] = audioread('riff.wav');

overDrive1 = distortion(riff,0.2,0.5);
overDrive2 = distortion(riff,0.4,0.5);
overDrive3 = distortion(riff,0.6,0.5);
overDrive4 = distortion(riff,0.8,0.5);
overDrive5 = distortion(riff,0.9,0.5);

% plots of different overdrives

len = size(riff,1);
t = 0:1/Fs:len/Fs;
t = t(1:len);

figure
subplot(3,2,1)
plot(t,riff)
title('original')
subplot(3,2,2)
plot(t,overDrive1)
title('gain = 0.2')
subplot(3,2,3)
plot(t,overDrive2)
title('gain = 0.4')
subplot(3,2,4)
plot(t,overDrive3)
title('gain = 0.6')
subplot(3,2,5)
plot(t,overDrive4)
title('gain = 0.8')
subplot(3,2,6)
plot(t,overDrive5)
title('gain = 0.9')

sound(overDrive5,Fs) % might wanna lower volume for this
pause(t(end))

%% 5. Single Tap Delay
[riff, Fs] = audioread('riff.wav');

len = size(riff,1);
t = 0:1/Fs:len/Fs;
t = t(1:len);

%delayed = delay(riff,0.5,240,1,Fs);
delayed = singletap(riff,0.8,40,0.2,Fs); % slapback effect
sound(delayed,Fs)
pause(t(end))
%%
delayed2 = singletap(riff,0.3,500,0.5,Fs); % cavern effect
sound(delayed2,Fs)
pause(t(end))
%% 
delayed3 = singletap(riff,0.1,220,0.5,Fs); % musical effect
sound(delayed3,Fs)
pause(t(end))

%% 6. Flanger
[drum, Fs] = audioread('In_The_Morning.wav');
len = size(drum,1);
t = 0:1/Fs:len/Fs;
t = t(1:len);

min_delay = 0.1; % in milliseconds
depth = 1; 
sweepDepth = 10;  % in milliseconds
rate = 1;         % in Hz
dflang = flanger(drum,depth,min_delay,sweepDepth,rate,Fs);

sound(dflang,Fs)
pause(t(end))

%% 7. Chorus
[riff, Fs] = audioread('riff.wav');

len = size(riff,1);
t = 0:1/Fs:len/Fs;
t = t(1:len);

min_delay = 0.1;
depth = 1;
sweepDepth = 10;
rate = 1;

riffChorus = flanger(riff,depth,min_delay,sweepDepth,rate,Fs);

sound(riffChorus,Fs)







