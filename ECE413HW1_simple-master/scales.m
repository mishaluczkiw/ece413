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
for i = 1:13
test(:,i) = circshift(JustScales(:,i),i-1);
end
test
for i = 1:12
    test(1:i,i+1) = test(1:i,i+1)/2;
end
test
