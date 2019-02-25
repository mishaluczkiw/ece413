function [soundOut] = create_sound(instrument,notes,constants)

%%%% Constants for SoundOut
fs = constants.fs;  % just to make it less cluttered afterwards
dur = constants.durationChord;
t = 0:1/fs:dur;
soundOut = zeros(1,length(t));


if size(notes,2) > 1 %call the function recursively to create the chords
    for i = 1:size(notes,2)
        [soundOut] = soundOut + create_sound(instrument,notes{i},constants);
    end
else
    
    
    
    
    
    
    %%%% Basic Constants from last HW assignment for frequnecies
    freq_ratios_just = [1 16/15 9/8 6/5 5/4 4/3 45/32 3/2 8/5 5/3 9/5 15/8 2];
    
    
    freq_ratios_eq = zeros(1,13);
    freq_ratios_eq(:) = 2;
    freq_ratios_eq(:) = freq_ratios_eq.^((0:12)/12);
    
    
    JustScales = zeros(12,13);
    for i = 1:12
        JustScales(i,1) = 440*freq_ratios_just(i);
        JustScales(i,:) = JustScales(i,1).*freq_ratios_just(:);
        %circshift(JustScales(i,:),i);
    end
    JustScales = JustScales/2; % avoid uncomfortable high frequencies
    
    % each row contains the frequencies of a key
    % missing the enharmonics
    EqualScales = zeros(12,13);
    EqualScales(1,:) = 440.*freq_ratios_eq;
    for i = 2:12
        EqualScales(i,:) = EqualScales(1,i).*freq_ratios_eq;
    end
    EqualScales = EqualScales/2;
    
    
    switch notes.note
        case 'A4'
            key = 1;
        case {'A4#', 'Bb4'}
            key = 2;
        case 'B4'
            key = 3;
        case 'C4'
            key = 4;
        case {'C4#','Db4'}
            key = 5;
        case 'D4'
            key = 6;
        case {'D4#','Eb4'}
            key = 7;
        case 'E4'
            key = 8;
        case 'F4'
            key = 9;
        case {'F4#','Gb4'}
            key = 10;
        case 'G4'
            key = 11;
        case {'G4#', 'Ab4'}
            key = 12;
        otherwise
            error('Inproper root specified');
    end
    
    switch instrument.temperament
        case 'Just'
            freq = JustScales(key,1);
        case 'Equal'
            freq = EqualScales(key,1);
        otherwise
            error('Inproper temperament specified');
    end
    
    
    switch instrument.sound
        case 'Additive'
            %% Additive Synthesis
            %Bell from Fig. 4.28 of Jerse
            %need to store 11 soundwaves
            
            soundOut = zeros(1,length(t));
            x = zeros(11,length(t)); % hold the soundwaves that will then be added one on top of the other
            
            amp = 1;
            
            
            
            % need to store different amplitudes
            amp_bell = amp.*[1,0.67,1,1.8,2.67,1.67,1.46,1.33,1.33,1,1.33];
            
            % need to store durations
            dur_bell = dur.*[1,0.9,0.65,0.55,0.325,0.35,0.25,0.2,0.15,0.1,0.75];
            
            % need to store different frequencies
            freq_bell = freq.*[0.56,0.56,0.92,0.92,1.19,1.7,2,2.74,3,3.76,4.07];
            freq_bell = freq_bell+[0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
            
            % implement envelope of exponential decay from 1 to 2^-10
            % exp(-6.93) ~= 2^-10
            envelopes = zeros(11,fs*dur);
            lin = zeros(11,fs*dur);
            
            for i = 1:11
                lin(i,1:fs*dur_bell(i)) = linspace(0,-6.93147, fs*dur_bell(i));
                envelopes(i,1:fs*dur_bell(i)) = exp(lin(i,1:fs*dur_bell(i)));
            end
            
            for i = 1:11
                x(i,1:fs*dur_bell(i)) = envelopes(i,1:fs*dur_bell(i)).*(amp_bell(i)*sin(2*pi*freq_bell(i)*t(1:fs*dur_bell(i))));
            end
            
            
            soundOut = sum(x);
            
            
            %% Time Varying Filter
        case 'Subtractive'
            %SOURCE:
            %Wah wah filter implementation taken online from:
            %http://users.cs.cf.ac.uk/Dave.Marshall/CM0268/PDF/10_CM0268_Audio_FX.pdf?fbclid=IwAR0hC_qLdpHKebz46wszP6JLikMvwtHzfL6VG0Jcup_h3Fax3nCthIvjpL4
            %page 24-30
            %changed Fc to only go from high to low, instead of oscillating between
            %high and low
            
            squareWave = zeros(1,length(t));
            squareWave(1:floor(fs/freq/2)) = 1;
            squareWave(floor(fs/freq/2)+1:floor(fs/freq)) = -1;
            len = length(repmat(squareWave(1:floor(fs/freq)),1,floor(length(t)/floor(fs/freq))));
            squareWave(1,1:len) = repmat(squareWave(1:floor(fs/freq)),1,floor(length(t)/floor(fs/freq)));
            x = squareWave;
            
            %%%%%%% EFFECT COEFFICIENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % damping factor
            % lower the damping factor the smaller the pass band
            damp = 0.05;
            % min and max centre cutoff frequency of variable bandpass filter
            diff = 100;
            minf=freq-diff;
            maxf=freq+diff;
            
            
            Fc = linspace(maxf,minf,length(x));
            % trim tri wave to size of input
            Fc = Fc(1:length(x));
            
            
            % difference equation coefficients
            % must be recalculated each time Fc changes
            F1 = 2*sin((pi*Fc(1))/fs);
            % this dictates size of the pass bands
            Q1 = 2*damp;
            yh=zeros(size(x));          % create emptly out vectors
            yb=zeros(size(x));
            yl=zeros(size(x));
            % first sample, to avoid referencing of negative signals
            yh(1) = x(1);
            yb(1) = F1*yh(1);
            yl(1) = F1*yb(1);
            % apply difference equation to the sample
            for n=2:length(x)
                yh(n) = x(n) - yl(n-1) - Q1*yb(n-1);
                yb(n) = F1*yh(n) + yb(n-1);
                yl(n) = F1*yb(n) + yl(n-1);
                F1 = 2*sin((pi*Fc(n))/fs);
            end
            
            %normalise
            maxyb = max(abs(yb));
            yb = yb/maxyb;
            
            soundOut = yb;
            
            
            
            
            %% FM Synthesis
        case 'FM'
            %parameters for bell sound
            fc = freq;  %carrier frequency
            fm = freq+80;  %modulation frequency
            IMAX = 10; %max modulation index
            fs = 44100;
            t = 0:1/fs:dur;
            
            env = zeros(1,fs*dur+1);
            env2 = zeros(1,fs*dur+1);
            env(:) = exp(linspace(-1.5,-6.93147, fs*dur+1)); %tweaked the initial amplitude from 1 to 0.35
            env2 = exp(linspace(-1,-5,fs*dur+1));
            
            soundOut = zeros(1,fs*dur+1);
            soundOut = env.*sin(2*pi*fc*t+IMAX*env.*sin(2*pi*fm*t));
            
            
            
            
            %% Waveshaping
        case 'Waveshaper'
            
            % ASD values from Fig. 5.28 in Jerse should create a clarinet sound
            Attack = floor(0.085*length(t));
            Sustain = floor(0.255*length(t)); %believe there is a typo in the book
            Decay = floor(0.66*length(t));
            
            soundIn = zeros(1,length(t));
            soundIn = (sin(2*pi*freq*t)+1)*256;
            soundOut = zeros(1,length(t));
            
            %apply piecewise linear transfer function
            for i = 1:length(t)
                if soundIn(i) >=0 && soundIn(i) <=200
                    soundOut(i) = -1+soundIn(i)*(0.5/200);
                else if soundIn(i) > 200 && soundIn(i) <= 312
                        soundOut(i) = -0.5+(soundIn(i)-200)*(1/112);
                    else if soundIn(i) > 312
                            soundOut(i) = 0.5+(soundIn(i)-312)*(0.5/200);
                        end
                    end
                end
            end
            
            %apply ASD enevelope
            
            soundOut(1:Attack) = linspace(0,1,Attack).*soundOut(1:Attack);
            soundOut(end-Decay+1:end) = linspace(1,0,Decay).*soundOut(end-Decay+1:end);
            
        otherwise error('Inproper instrument.sound specified');
    end
    
end



end