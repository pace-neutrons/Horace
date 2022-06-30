classdef DataMessage < aMessage
    % The class describes the message, which contains data.
    %
    % Usually, data are big, so copying efficiency is important.
    %
    %
    methods
        function obj = DataMessage(payload)
            % Construct the data message
            % Inputs:
            % payload  -- if not empty, assigns the value, provided as
            %             input to payload property.
            % 
            obj = obj@aMessage('data');
            if exist('payload', 'var')
                obj.payload = payload;
            end
        end
    end
    methods(Static,Access=protected)
        function isblocking = get_blocking_state()
            % return the blocking state of a message
            isblocking = true;
        end
    end
    
    
end

