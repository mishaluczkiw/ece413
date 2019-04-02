function [event, meta_event, shift,True] = metaEvent(raw,index)

% Checks whether a meta-event is present: records the event, the type, and the shift in position induced by the event, which
% if added to the index points to the last byte in the event

event = nan;
meta_event = nan;
%delta = nan;
shift = 0;
True = 0;
if index < size(raw,1)
    if raw(index) == 240 % 0xF0 sysex event (ignore)
        True = 1;
        event = 240;
        meta_event = nan;
        [tracknameLength,tmplen] = variableLength(raw,index+1);
        Text = char(raw(index+1+tmplen:index+2+tmplen+tracknameLength))'
            
        shift = 1+tmplen+tracknameLength;
        
    end
    
    if raw(index) == 247 % 0xF7 sysex event (ignore)
        True = 1;
        event = 247;
        meta_event = nan;
        [tracknameLength,tmplen] = variableLength(raw,index+1);
        %Text = char(raw(index+1+tmplen:index+2+tmplen+tracknameLength))'
            
        shift = 1+tmplen+tracknameLength;
        
    end
    
    
    if raw(index) == 255  && raw(index+1)<128       % FF  meta-event (event type is always less than 128)
        True = 1;                                   % a flag to know there is an event
        event = raw(index);                         % store event type
        
        %delta = reverse_variableLength(raw,index-1); % store delta time
        
        meta_event = raw(index+1);                  % store meta_event type
       
        
        if meta_event == 1  % 0x1 Text Event (ignore)
            
            [tracknameLength,tmplen] = variableLength(raw,index+2);
            Text = char(raw(index+2+tmplen:index+2+tmplen+tracknameLength))'
            
            shift = 2+tmplen+tracknameLength;
            
        end
        
        if meta_event == 3  % 0x3 Track Name (ignore)
            
            [tracknameLength,tmplen] = variableLength(raw,index+2);
            trackName = char(raw(index+2+tmplen:index+2+tmplen+tracknameLength))'
            
            shift = 2+tmplen+tracknameLength;
            
        end
        
        
        if meta_event == 4  %0x4 Instrument Name(ignore)
            [tracknameLength,tmplen] = variableLength(raw,index+2);
            instrumentName = char(raw(index+2+tmplen:index+2+tmplen+tracknameLength))'
            
            shift = 2+tmplen+tracknameLength;
        end
        
        if meta_event == 81  % 0x51 Set Tempo
            tempo = bi2de(reshape(de2bi(flipud(raw(index+3:index+5)),8,'right-msb')',[1 24]),'right-msb');
            
            shift = 6;
            
        end
        
        if meta_event == 84  % 0x54 SMPTE Offset
            
            shift = 7;
        end
            
        
        if meta_event == 47  % 0x2F End of Track
            % not sure what to do yet
            shift = 2;
        end
        
        if meta_event == 33 % don't know what this is, but it's in Furelise file
            shift = 4;
        end
        
        
        if meta_event == 88  % 0x58 Time Signature
            numerator = raw(index+3);
            denominator = 2^raw(index+4);
            cc = raw(index+5);             % number of MIDI clocks in a metronome click
            bb = raw(index+6);             % number of 32nd notes in what MIDI thinks of as a quareter note (23 MIDI clocks) ?
            
            shift = 6;
            
          
        end
        
        
    end
    
    
    
end