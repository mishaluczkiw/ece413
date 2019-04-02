% MIDI processor
% retrieves all the data information from the midifile specified in fopen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Open Midi file for reading
clc
close all
clear functions
clear variables
dbstop if error

%arrayNotes = objNote.empty;

%arrayNotes(1) = objNote(parameters);


fileID = fopen('mario.mid'); % open MIDI file
raw = fread(fileID);            % Store the MIDI file in bytes

% initialize variables
total_time = 0;
num_of_events = 0;
event=nan(3,size(raw,2));     % first row: the event type
                              % second: only for meta-event specification
                              % third row: time since THE BEGINNING
num_of_notes = 0;                          
notes = nan(3,size(raw,2));   % first row: noteNumber
                              % second row: velocity
                              % third row: type: 1 = On, 2 = Off
                              % fourth row: time since THE BEGINNING


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Header Chunck %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% raw(1:4) is the MThd Ascii characters
hexRepresentation = char.empty(0,size(raw,1));

%convert file to hexadecimal for easier interpretation

for i = 1:size(raw,1) % might slow down processing
    hexRep(1,2*i-1:2*i) = dec2hex(raw(i));
end
hexRep2 = hexRep(1:30*32);
hexRep2 = reshape(hexRep2,[32 30])';


% retrieving length in the 32-bit representation
% convert to binary, reshape so its 32 bits long and then reconvert back to
% decimal
length = bi2de(reshape(de2bi(flipud(raw(5:8)),8,'right-msb')',[1 32]),'right-msb');
%length is #bytes to follow without including eight bytes of type and
%length

format = raw(10) %either 0, 1, or 2
% only check raw(10) since the number for format can't be bigger than 2, so
% the msb would not be anything other than 0

% ntrks is the number of tracks in the file
% since the time signature is always specified in two bytes, the length of
% ntrks will be length-2(format)-2(division) bytes
ntrks = bi2de(reshape(de2bi(flipud(raw(11:11+length-5)),8,'right-msb')',[1 8*(length-4)]),'right-msb')

% division specifies the meaning of the delta times
% two formats: metrical time, time-code-based time

division_bin = reshape(de2bi(flipud(raw(11+length-5+1:11+length-5+1+1)),8,'right-msb')',[1 16]);
if division_bin(1) == 0 %bits 14 thru 0 represent the number of delta-ticks which make up a quarter note
    ppqn = bi2de(division_bin,'right-msb'); %don't need to worry about msb, since it is zero by default
    if ppqn == 0 % ie. when not specified
        ppqn = 120; %default value
    end
else if division_bin(1) == 1 %delta times in a file correspond to subdivisions of a second consistent w/ SMPTE
        
        frames_per_second = -de2bi([division_bin(2) zeros(1,5)],'left-msb')+de2bi(division_bin(3:7),'left-msb'); %needs to be in two's complement, can only be either -24,-25,-29,-30
        ticks_per_frame = de2bi(division_bin(8:end),'left-msb');
    end
end

cursor = 11+length-5+1+1; %just to keep track where I am in the file in bytes

cursor = cursor +1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Next Tracks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%iterate through all the tracks


for trk = 1:ntrks
    trk
    if format == 1  %for track type 1 the tracks are played simultaneously
        total_time = 0;
    end
    
    if sum(char(raw(cursor:cursor+3))==['M';'T';'r';'k']) == 4% sanity check to make sure a track comes afterwards
        cursor = cursor + 4;   % first four bytes of any track are the ascii characters 'MTrk' so skip
        fprintf(1,'New Track at %d \n',cursor);                       
    end
    
    %startTrack = cursor
    trkLength = bi2de(reshape(de2bi(flipud(raw(cursor:cursor+3)),8,'right-msb')',[1 32]),'right-msb')
    cursor = cursor+4; % Length of Track in bytes
    startTrack = cursor;

    while cursor<startTrack+trkLength
        index = cursor;
        
       
        [delta shift1] = variableLength(raw,index);
        
        index = index + shift1;
                                
        
            [FEvent, meta_event, shift2, flagEvent] = metaEvent(raw,index);
      
            
            if flagEvent == 1
                fprintf(1,'Event at %d\n',index);
                num_of_events = num_of_events + 1;
                total_time = total_time+delta;
                event(1,num_of_events) = FEvent;
                event(2,num_of_events) = meta_event;
                event(3,num_of_events) = total_time;
                
                if meta_event == 81  % 0x51 Set Tempo
                    tempo = bi2de(reshape(de2bi(flipud(raw(index+3:index+5)),8,'right-msb')',[1 24]),'right-msb');
                end
                
                %index = index + shift2;  % bring the index to the next thing to look at
                
                if meta_event == 89        % 0x59 Key Signature (need to store)
                    sf = raw(cursor+3);    % negative: # of flats, pos.: # of sharps
                    mi = raw(cursor+4);    % 0 maj, 1 min
                    shift2 = 4;
                end
                
                if meta_event == 47        % End of Track
                    fprintf(1,'End of Track\n');
                    %index = cursor+trkLength-1; % avoids index at the end of file, to create Error
                end
                flagEvent = 0;
            end
            
            
            [noteNumber,velocity,type,flagNote,shift3,RunningStatus] = checkNote(raw,index);
            
            if flagNote == 1 && RunningStatus ~= 1 % no Running Status
                fprintf(1,'Note %d at %d \n', num_of_notes, index);
                num_of_notes = num_of_notes + 1;
                total_time = total_time+delta;
                
                notes(1:4,num_of_notes) = [noteNumber;velocity;type;total_time];
                runlength = 0;         % used in RunningStatus to differentiate between first and second time entering
                %index = index + shift3;
            end
            
            runlength = 0;
            if flagNote == 1 && RunningStatus == 1 && flagEvent ~= 1
                 %type = 1; % always Note On in Running Status
                 %runlength = 2;
                 while RunningStatus == 1
                 fprintf(1,'Running Status at %d, note number %d \n',index+runlength,num_of_notes);
                 num_of_notes = num_of_notes + 1;
                 total_time = total_time+delta;
                 [noteNumber,velocity,flag,shift,deltalen,delta,RunningStatus] = runNote(raw,index+1+runlength); % check running Status
                 notes(1:4,num_of_notes) = [noteNumber;velocity;type;total_time]; % store the values from before
                 
                 

                 runlength = runlength+2+deltalen; % keep track of how long running status is, to shift accordingly
                 %total_time = total_time+delta;
                 
                 end
               
                
                
                
            end
       %if cursor >250 && cursor <324     
       %shift1
       %shift2
       %shift3
       %cursor
       %end
        
        cursor = cursor+shift1+shift2+shift3+runlength; % cursor updated to length of event/note
        
        
        
    end
    
    cursor = startTrack + trkLength; % bring cursor to beginning of new Track
end
notes;
event;

%%
% This is a simple test script to demonstrate all parts of HW #1
                                                                        % add dynamic break point

% PROGRAM CONSTANTS
constants                              = confConstants;
constants.BufferSize                   = 882;                                                    % Samples
constants.SamplingRate                 = 44100;                                                  % Samples per Second
constants.QueueDuration                = 0.1;                                                    % Seconds - Sets the latency in the objects
constants.TimePerBuffer                = constants.BufferSize / constants.SamplingRate;          % Seconds;

oscParams                              =confOsc;
oscParams.oscType                      = 'sine';
oscParams.oscAmpEnv.StartPoint         = 0;
oscParams.oscAmpEnv.ReleasePoint       = Inf;   % Time to release the note
oscParams.oscAmpEnv.AttackTime         = .02;  %Attack time in seconds
oscParams.oscAmpEnv.DecayTime          = .01;  %Decay time in seconds
oscParams.oscAmpEnv.SustainLevel       = 0.7;  % Sustain level
oscParams.oscAmpEnv.ReleaseTime        = .05;  % Time to release from sustain to zero

%% Convert parsed notes to something objTone can read


% just to reitarate how notes is structured
        % first row: noteNumber
        % second row: velocity
        % third row: type: 1 = On, 2 = Off, 3 =
        % patchchange
        % fourth row: time since THE BEGINNING in ticks




arrayNotes = zeros(size(notes));
% how arrayNotes is structured
% row 1: noteNumber
% row 2: amplitude
% row 3: startTime
% row 4: endTime (calculated)
true_num_of_notes = 1;
breaker = false;
one_or_two = 1;
for index = 1:size(notes,2)
    breaker = false;
    
    if notes(2,index) > 0  && notes(3,index) == 1 % avoid checking from note off
        for index2 = index+1:size(notes,2)
            
            if (index2 < size(notes,2)) && (notes(1,index)==notes(1,index2))  && (((notes(3,index) == 1 && (notes(3,index2) == 2||notes(2,index2)==0)))) && breaker == false
                % if index2 not at the end AND note 1 and note 2 are the same
                % AND(note 1 is On AND (note 2 is Off OR note 2 has velocity 0)
                
                
                arrayNotes(1,true_num_of_notes) = notes(1,index);                   % store noteNumber
                arrayNotes(2,true_num_of_notes) = notes(2,index);                   % store only On amplitude
                arrayNotes(3,true_num_of_notes) = notes(4,index);                   % store startTime
                arrayNotes(4,true_num_of_notes) = notes(4,index2);                  % store endTime
                
                true_num_of_notes = true_num_of_notes + 1;
                breaker = true;
                
            end
            
        end
    end
    
end

% convert delta times into seconds

% (Assumption: one tempo throughout
% for actually converting right notes to the right tempo, need to check
% events for when tempo event happens, and change based on time when that
% happens)

% Time = ticks*tempo/ppqn [seconds]
arrayNotes(3,:) = arrayNotes(3,:)*(tempo/ppqn)/1000000;
arrayNotes(4,:) = arrayNotes(4,:)*tempo/ppqn/1000000;
arrayNotes = arrayNotes(:,1:true_num_of_notes);

% normalize amplitudes
arrayNotes(2,:) = arrayNotes(2,:)/127;
arrayNotes;



%% play Sound  

% set correct key
majKeys_sharps = {'G','D','A','E','B','F#','C#'};
majKeys_flats = {'F','Bb','Eb','Ab','Db','Gb','Cb'};

minKeys_sharps = {'E','B','F#','C#','G#','D#','Bb'};
minKeys_flats = {'D','G','C','F','Bb','Eb','G#'};
switch mi %major/ minor
    case 0
        if sf == 0
            key = 'C';
        end
        if sf < 0 % flats
            key = majKeys_flats(sf);
        end
        if sf > 0 % sharps
            key = majKeys_sharps(sf);
        end
    case 1
        if sf == 0
            key = 'A';
        end
        if sf < 0 % flats
            key = minKeys_flats(sf);
        end
        if sf > 0 % sharps
            key = minKeys_sharps(sf);
        end
end
            
            
    
% input parameters: startingNoteNumber, temeperament, 'key', beat,
% amplitude, startTime, endTime
tone2 = objTone(arrayNotes(1,:),'just',key,ppqn,arrayNotes(2,:)/3,arrayNotes(3,:),arrayNotes(4,:));


playAudio(tone2,oscParams,constants);
