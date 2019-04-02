function [delta, len] = variableLength(raw,cursor)

%%%%%%%%%%%%%%%%%% implement variable length delta time %%%%%%%%%%%%%%%%%%%
% Return delta time and length of the delta time

delta_bin = de2bi(raw(cursor),8,'left-msb'); % store delta in binary
varLength = 1;           % store length of delta time

% checks the 7th msb bit, which in my case is the first bit to know
% whether the next byte is part of the delta time
% if this is true the while loop appends the next byte without the most
% significant bit
if cursor+varLength <= size(raw,1) % in order not to check beyond the end of the file
    append = de2bi(raw(cursor+varLength),8,'left-msb');
    
    while delta_bin(1+(varLength-1)*8) == 1
        delta_bin = [delta_bin, append];
        varLength = varLength +1;
        append = de2bi(raw(cursor+varLength),8,'left-msb');
    end
end
delta_tmp = zeros(1,7*varLength);
for i=1:varLength % eliminate unwanted zeros
    %delta_tmp(1:7) = delta_bin(2:8)
    %delta_tmp(8:14) = delta_bin(10:16)
    % ...
    delta_tmp(1+(i-1)*7:7+(i-1)*7) = delta_bin(2+(i-1)*8:8+(i-1)*8);
    
end
%cursor = cursor + varLength; % now we're at the byte after the delta
delta_tmp;
delta_bin;
delta = bi2de(delta_tmp,'left-msb');
len = varLength;



end