function hex = dec2hex(dec)
% Convert decimal number ranging from 0-255 into a two digit hexadecimal
% number
% Converts one number at a time


HEXi = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];

first_digit = floor(dec/16);
second_digit = rem(dec,16);

hex = [HEXi(first_digit+1), HEXi(second_digit+1)];

end