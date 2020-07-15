classdef StartingMessage < aMessage
    % The class the message, indicating the beginning of a task.
    %
    % The message is a data message, so should always be received
    % synchronously
    %
    %
    methods
        function obj = StartingMessage (inputs)
            % Construct the data message
            obj = obj@aMessage('starting');
            if nargin>0
                obj.payload = inputs;
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

