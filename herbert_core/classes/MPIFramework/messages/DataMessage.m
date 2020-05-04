classdef DataMessage < aMessage
    % The class describes the message, which contains data.
    %
    % Usually, data are big, so copying efficiency is important.
    %
    %
    % $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
    %
    %
    methods
        function obj = DataMessage(payload)
            % Construct the data message
            obj = obj@aMessage('data');
            if exist('payload','var')
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

