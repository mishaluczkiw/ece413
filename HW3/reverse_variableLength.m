function deltaTime = reverse_variableLength(raw,cursor)


 %%%%%%%%%%%%%%%%%% implement variable length delta time backwards%%%%%%%%%
        delta_bin = de2bi(raw(cursor),8,'left-msb'); % store delta in binary
        delta_bin = delta_bin(2:8);
        varLength = 1;           % store length of delta time
        delta_bin_check = de2bi(raw(cursor-varLength),8,'left-msb');
        
        % checks the the 7th bit of the previous byte
        % if it is zero, then it is not part of the delta time
        % if it is one, then it is part of the delta time and the
        % preceding byte needs to be checked

        while delta_bin_check(1) == 1
            append = delta_bin_check;
            delta_bin = [append(2:8),delta_bin]
            varLength = varLength +1;
            delta_bin_check = de2bi(raw(cursor-varLength),8,'left-msb');
        end
        
        
        deltaTime = bi2de(delta_bin,'left-msb');


end