classdef FailedMessage < aMessage
    % Helper class defines a Failure message, used to inform
    % head-node and (possibly) other nodes that the job have failed.
    %
    %
    % $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
    %
    %
    properties(Dependent)
        %
        fail_text
        exception
    end
    properties(Access = protected)
        fail_text_ = '';
    end
    
    methods
        function obj = FailedMessage(fail_text,error_exception)
            % Construct the initialization message
            %
            % Inputs:
            % fail_text  -- the text which describes the error
            % error_exception -- the class of the Matlab exception type,
            %               which  describes the caught exception
            %
            obj = obj@aMessage('failed');
            
            if ~exist('error_exception','var')
                ex_text = 'automatic exception, generated at FailedMessage without arguments: ';
                if exist('fail_text','var')
                    ex_text  = [ex_text,fail_text];
                end
                error_exception = MException('FAILED_MESSAGE:no_aruments',...
                    ex_text);
            end
            if ~exist('fail_text','var')
                fail_text = ' Failed message without parameters';
            end
            
            obj.fail_text_  = fail_text;
            obj.payload     = error_exception;
        end
        
        function text = get.fail_text(obj)
            text =obj.fail_text_;
        end
    end
end


