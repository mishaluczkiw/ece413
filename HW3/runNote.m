function [noteNumber,velocity,flag,shift,deltalen,delta,RunningStatus] = runNote(raw,cursor)
% Only used when Running Status is detected
% Returns note numbers and velocities until the end of the Running status
% also checks for delta times

noteNumber = nan;
velocity = nan;
%type = nan;
%delta = nan;
flag = 0; % if 1 means this is indeed a Running Status
shift = 0; % shift induced by Running Status
RunningStatus = 0; % if 1 means Running Status continues afterwards
deltalen = 0; % variable length after note

if raw(cursor) > 21 && raw(cursor) < 108 % max and minimum Midi Note numbers
    flag = 1;
    noteNumber =  raw(cursor);
    velocity = raw(cursor+1);
    shift = 2;
end

if cursor+shift < size(raw,1) && flag == 1 % always make sure not to check beyond the end of file
    [delta deltalen] = variableLength(raw,cursor+shift);
end

if cursor+shift+deltalen < size(raw,1) && flag == 1 % do not check beyond end of the file
    if raw(cursor+shift+deltalen) < 128 % means there's no command but a note
        RunningStatus = 1;
    end
end



end
