classdef FailMessage < aMessage
    % Helper class desfines a Fauk message, used to transfer initial
    % information to a single task of a distributed job.
    %
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
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
        function obj = FailMessage(fail_text,error_exception)
            % Construct the intialization message
            %
            % Inputs:
            % fail_text  -- the text which describes the error
            % error_exception -- the class of the Matlab exception type,
            %               which  describes the caught exception
            %
            if ~exist('error_exception','var')
                ex_text = 'automatic exception, generated at FailMessage without arguments: ';
                if exist('fail_text','var')
                    ex_text  = [ex_text,fail_text];
                end
                error_exception = MException('FAIL_MESSAGE:no_aruments',...
                    ex_text);
            end
            if ~exist('fail_text','var')
                fail_text = ' Failed message without parameters';
            end
            
            obj = obj@aMessage('failed');
            obj.fail_text_  = fail_text;
            obj.payload     = error_exception;
        end
        
        function text = get.fail_text(obj)
            text =obj.fail_text_;
        end
    end
    %    methods(Access=protected)
    %         function pl = get_payload(obj)
    %             if isempty(obj.payload_)
    %                 pl = obj.exception_;
    %             else
    %                 if isempty(obj.exception_)
    %                     pl = obj.payload_;
    %                 else
    %                     pl  = {obj.exception_,obj.payload_};
    %                 end
    %             end
    %
    %         end
    %    end
    
end

