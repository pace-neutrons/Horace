classdef CancelledMessage < aMessage
    % Helper class defines a Cancellation message, used to inform
    % head-node and possibly other nodes that the job have been cancelled.
    %
    % Construct the "Cancelled" message
    %
    % Inputs:
    % fail_text  -- the text which describes the error
    % error_exception -- the class of the Matlab exception type,
    %                    which  contains the information about the
    %                    problem.
    % If no arguments are provided, default text and MException are
    % used, though they do not contain any useful information about
    % the problem.
    
    properties(Dependent)
        % The custon text, containig custom information about the failure
        fail_text
    end
    properties(Access = protected)
    end
    
    methods
        function obj = CancelledMessage(varargin)
            % Construct the Cancelled message
            %
            % Inputs:
            % fail_text  -- the text which describes the error
            % error_exception -- the class of the Matlab exception type,
            %                    which  contains the information about the
            %                    problem.
            % If no arguments are provided, default text and MException are
            % used, though they do not contain any useful information about
            % the problem.
            %
            obj = obj@aMessage('cancelled');
            if nargin>0
                obj.payload     = varargin{1};
            end
            
        end
        function text = get.fail_text(obj)
            if isempty(obj.payload)
                text = '';
                return
            end
            if isa(obj.payload,'MException')
                text =obj.payload_.message;
            else
                text = evalc('disp(obj.payload)');
            end
        end
        
    end
    methods(Static,Access=protected)
        function is_pers = get_persist_state()
            % return the persistent state for a message
            is_pers = true;
        end
    end
    
end


