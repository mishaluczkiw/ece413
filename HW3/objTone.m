% First draft a Scale Object

classdef objTone
    properties
        % These are the inputs that must be provided
        %scaleType                                                           % major or minor
        startingNoteNumber                                                  % MIDI note number
        temperament                 = 'equal'                               % Default to equal temperament
        key                         = 'C'                                   % Default to key of C
        amplitude                   = 1                                     % Amplitude of the notes in the scale
        startTime                   = 0
        endTime                     = 1
        % Defaults
        tempo                       = 120                                   % Beats per minute
        noteDurationFraction        = 0.8                                   % Duration of the beat the note is played for 
        breathDurationFraction      = 0.2                                   % Duration pf the beat that is silent
        
        % Calculated
        secondsPerQuarterNote                                               % The number of seconds in a quarterNote
        noteDuration                                                        % Duration of the note portion in seconds
        breathDuration                                                      % Duration of the breath portion in seconds
        arrayNotes                  = objNote.empty;                        % Array of notes for the scale
    end
    
    properties (Constant = true, GetAccess = private)
        % Constants
        majOffsets=[2 2 1 2 2 2 1];                                         % Half steps between notes in the major scale
        minOffsets=[2 1 2 2 1 2 2];                                         % Half steps between notes in the minor scale
    end
    methods
        function obj = objTone(varargin)
            
            % Map the variable inputs to the class
            if nargin >=7
                obj.endTime = varargin{7};
            end
            if nargin >=6
                obj.startTime=varargin{6};
            end
            if nargin >=5
                obj.amplitude=varargin{5};
            end
            if nargin >= 4
                obj.tempo=varargin{4};
            end
            if nargin >= 3
                obj.key=varargin{3};
            end
            if nargin >= 2
                obj.temperament=varargin{2};
            end
            obj.startingNoteNumber=varargin{1};
            
            
            % Compute some constants based on inputs
            %obj.secondsPerQuarterNote       = 60\obj.tempo;  %changed / to \                     
            %obj.noteDuration                = obj.noteDurationFraction*obj.secondsPerQuarterNote;         % Duration of the note in seconds (1/4 note at 120BPM)
            %obj.breathDuration              = obj.breathDurationFraction*obj.secondsPerQuarterNote;         % Duration between notes
            
            
            
            % Select the pattern between notes based on the scale selected
            %switch obj.scaleType
            %    case {'major','Major'}
            %        offsets=obj.majOffsets;
            %    case {'minor','Minor'}
            %        offsets=obj.minOffsets;
            %    otherwise
            %        error('Scale not defined');
            %end
            
            % Walk through the offsets and build the scale
            currentNoteNumber=obj.startingNoteNumber;
            %startTime=0;
            startTime=obj.startTime;
            endTime = obj.endTime;
            %endTime=startTime+obj.noteDuration;
            amplitudeNote=obj.amplitude;
            for cnt=1:length(currentNoteNumber)
                

                obj.arrayNotes(cnt)=objNote(currentNoteNumber(cnt),obj.temperament,obj.key,startTime(cnt),endTime(cnt),amplitudeNote(cnt));
                
                %if cnt <= length(offsets)
                %    currentNoteNumber=currentNoteNumber+offsets(cnt);
                %    startTime=startTime+obj.breathDuration+obj.noteDuration;
                %    endTime=endTime+obj.breathDuration+obj.noteDuration;
                %end
                
            end
        end
    end
end
