function [soundOut] = create_chord( chordType,temperament, root, constants )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%    [ soundOut ] = create_scale( chordType,temperament, root, constants )
% 
% This function creates the sound output given the desired type of chord
%
% OUTPUTS
%   soundOut = The output sound vector
%
% INPUTS
%   chordType = Must support 'Major' and 'Minor' at a minimum
%   temperament = may be 'just' or 'equal'
%   root = The Base frequeny (expressed as a letter followed by a number
%       where A4 = 440 (the A above middle C)
%       See http://en.wikipedia.org/wiki/Piano_key_frequencies for note
%       numbers and frequencies
%   constants = the constants structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% list of frequency ratios of the complete scale of Just Intonation
% chose augmented fourth over diminished fifth, left out harmonic and grave
% minor seventh and chose minor seventh instead

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
    

switch root
    case 'A'
        key = 1;
    case {'A#', 'Bflat'}
        key = 2;
    case 'B'
        key = 3;
    case 'C'
        key = 4;
    case {'C#','Dflat'}
        key = 5;
    case 'D'
        key = 6;
    case {'D#','Eflat'}
        key = 7;
    case 'E'
        key = 8;
    case 'F'
        key = 9;
    case {'F#','Gflat'}
        key = 10;
    case 'G'
        key = 11;
    case {'G#', 'Aflat'}
        key = 12;
    otherwise
        error('Inproper root specified');
end


switch chordType
    case {'Major','major','M','Maj','maj'}
        interval = [1 5 8];
    case {'Minor','minor','m','Min','min'}
        interval = [1 4 8];
    case {'Power','power','pow'}
        interval = [1 5];
    case {'Sus2','sus2','s2','S2'}
        interval = [1 3 8];
    case {'Sus4','sus4','s4','S4'}
        interval = [1 6 8];
    case {'Dom7','dom7','Dominant7', '7'}
        interval = [1 5 8 11];
    case {'Min7','min7','Minor7', 'm7'}
        interval = [1 4 8 11];
    otherwise
        error('Inproper chord specified');
end

switch temperament
    case {'just','Just'}
        ChordVector = JustScales(key,interval);
    case {'equal','Equal'}
        ChordVector = EqualScales(key,interval);
    otherwise
        error('Inproper temperament specified')
end


% Complete with chord vectors
t = 0:1/constants.fs:constants.durationChord;
soundOut = zeros(1,length(t));
x = zeros(4,length(t));
for note = 1:length(interval)
    x(note,:) = sin(2*pi*ChordVector(note)*t);
end

soundOut = x(1,:)+x(2,:)+x(3,:)+x(4,:);


end
