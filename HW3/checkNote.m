function [noteNumber,velocity,type,flag,shift,RunningStatus] = checkNote(raw,cursor)
% Checks if byte is a Note on, Note off or Patch change
% Controller Command
% Returns noteNumber, Velocity,
% type of command:
% 1 = Note On
% 2 = Note Off
% 3 = Patch Change --> shift by 2
% 4 = Controller Command (ignored for know)
% delta

noteNumber = nan;
velocity = nan;
type = nan;
%delta = nan;
flag = 0;
shift = 0;
RunningStatus = 0;

if cursor < size(raw,1) % make sure not to be out of bounds
    
    if (raw(cursor)>=128 && raw(cursor)<=159) || (raw(cursor)>=176 && raw(cursor)<=207) % check if Note
        flag = 1;
        %delta = reverse_variableLength(raw,cursor-1);
    end
    
    if raw(cursor) == 96 || raw(cursor) == 97 || raw(cursor) == 91 % data entry, do nothing
        shift = 0;
    end
        
    
end
if flag == 1
    if raw(cursor) >= 128 && raw(cursor) <=143 % Note Off
        noteNumber = raw(cursor+1);
        velocity = raw(cursor+2);
        type = 2;
    end
    
    if raw(cursor) >= 144 && raw(cursor) <=159 % Note On
        noteNumber = raw(cursor+1);
        velocity = raw(cursor+2);
        type = 1;
    end
    
    if raw(cursor) >= 192 && raw(cursor) <=207 % PatchChange
        noteNumber = raw(cursor+1); % which is the patchChange
        type = 3;
    end
    
    if raw(cursor) >= 176 && raw(cursor) <=191 % Controller Command
        noteNumber = raw(cursor+1);
        velocity = raw(cursor+2);
        type = 4;
    end
    
    % set shift according to type
    
    if type == 1 || type == 2 || type == 4
        shift = 3;
    end
    if type == 3;
        shift = 2;
    end
    
    
    % Check Running Status
    if cursor+shift < size(raw,1) % always make sure not to check beyond the end of file
        [zzz deltalen] = variableLength(raw,cursor+shift);
    end
    
    if cursor+shift+deltalen < size(raw,1) && type ~= 3 && type ~= 4% only valid for note on and off
        if raw(cursor+shift+deltalen) < 128 % means there's no command but a note
            RunningStatus = 1;
            shift = 3;
        end
    end
    
    
end

end
