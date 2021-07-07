classdef CompletedMessage < aMessage
    % The class the message, indicating the end of a task.
    %
    % The message is persistent as should stay in the system until
    % "ClearAll" signal is received.
    %
    %
    methods
        function obj = CompletedMessage(varargin)
            % Construct the data message
            obj = obj@aMessage('completed');
            if nargin>0
                obj.payload = varargin{:};
            end
        end
    end
    methods(Static,Access=protected)
%         function is_pers = get_persist_state()
%             % return the persistent state for a message
%             is_pers = true;
%         end
    end
end

