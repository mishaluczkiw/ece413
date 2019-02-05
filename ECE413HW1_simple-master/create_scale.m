function [soundOut] = create_scale( scaleType,temperament, root, constants )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%    [ soundOut ] = create_scale( scaleType,temperament, root, constants )
% 
% This function creates the sound output given the desired type of scale
%
% OUTPUTS
%   soundOut = The output sound vector
%
% INPUTS
%   scaleType = Must support 'Major' and 'Minor' at a minimum
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
% TODO: Add all relavant constants 


t = 0:1/constants.fs:constants.durationScale;
soundOut = zeros(1,8*length(t));
numberofKeys = 8;

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
%Scales = Scales'

% each row contains the frequencies of a key
% missing the enharmonics
EqualScales = zeros(12,13);
EqualScales(1,:) = 440.*freq_ratios_eq;
for i = 2:12
    EqualScales(i,:) = EqualScales(1,i).*freq_ratios_eq;
end
EqualScales = EqualScales/2;

test = zeros(size(JustScales));
for i = 1:12
test(:,i) = circshift(JustScales(:,i),i-1);
end
test
ScaleVector = zeros(1,8);

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


switch scaleType
    case {'Major','major','M','Maj','maj'}
       interval = [2 2 1 2 2 2 1];
	% TODO: Complete with interval pattern for the major scale
    case {'Minor','minor','m','Min','min'}
       interval = [2 1 2 2 1 2 2];
	% TODO: Complete with interval pattern for the minor scale
    case {'Harmonic', 'harmonic', 'Harm', 'harm'}
       interval = [2 1 2 2 1 3 1];
	% EXTRA CREDIT
    case {'Melodic', 'melodic', 'Mel', 'mel'}
       interval = [2 1 2 2 1 2 2 -2 -2 -1 -2 -2 -1 -2];
       numberofKeys = 15;
       %soundOut = zeros(1,num*length(t));
       
       
	% EXTRA CREDIT
    otherwise
        error('Inproper scale specified');
end

switch temperament
    case {'just','Just'}
	% TODO: Pull the Just tempered ratios based on the pattern from the scales
    ScaleVector = JustScales(key,[1 cumsum(interval)+1]);
    case {'equal','Equal'}
	% TODO: Pull the equal tempered ratios based on the pattern from the scales
    ScaleVector = EqualScales(key,[1 cumsum(interval)+1]);
    
    otherwise
        error('Improper temperament specified')
end



% Create the vector based on the notes
soundOut = zeros(1,numberofKeys*length(t));
for tone = 1:numberofKeys
    soundOut(length(t)*(tone-1)+1:length(t)*tone) = sin(2*pi*ScaleVector(tone)*t);
end


end
