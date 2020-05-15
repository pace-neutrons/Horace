classdef FailedMessage < aMessage
    % Helper class defines a Failure message, used to inform
    % head-node and (possibly) other nodes that the job have failed.
    %
    properties(Dependent)
        % The custon text, containig custom information about the failure
        fail_text
        
        % The field containing the Matlab exception, thrown by the program
        % and containing information about the failure.
        %
        % if message was deserialized, the exception is converted into
        % MException_her class, as standard MException can not be
        % deserialized
        exception
    end
    properties(Access = protected)
    end
    
    methods
        function obj = FailedMessage(fail_text,error_exception)
            % Construct the initialization message
            %
            % Inputs:
            % fail_text  -- the text which describes the error
            % error_exception -- the class of the Matlab exception type,
            %                    which  contains the information about the
            %                    problem.
            %
            obj = obj@aMessage('failed');
            
            if ~exist('error_exception','var')
                ex_text = 'automatic exception, generated at FailedMessage without arguments: ';
                if exist('fail_text','var')
                    ex_text  = [ex_text,fail_text];
                end
                error_exception = MException_her('FAILED_MESSAGE:no_aruments',...
                    ex_text);
            end
            if ~exist('fail_text','var')
                fail_text = ' Failed message without parameters';
            end
            
            obj.payload     = struct('fail_reason',fail_text,...
                'error',error_exception);
        end
        function struc = saveobj(obj)
            %
            if ~isempty(obj.payload) && isstruct(obj.payload)...
                    && isa(obj.payload.error,'MException')
                obj.payload.error = MException_her(obj.payload.error);
            end
            struc = saveobj@aMessage(obj);
        end
        
        function text = get.fail_text(obj)
            if iscell(obj.payload_)
                text =obj.payload_{1}.fail_reason;
                
            else
                text =obj.payload_(1).fail_reason;
            end
        end
        function text = get.exception(obj)
            if iscell(obj.payload_)
                text =obj.payload_{1}.error;
            else
                text =obj.payload_(1).error;
            end
        end
    end
    methods(Static,Access=protected)
        function is_pers = get_persist_state()
            % return the persistent state for a message
            is_pers = true;
        end
%         function struc_r = replace_mexc_(struc)
%             % function replaces reference to MException class, which is not
%             % restorable at de-serialization to the reference to
%             % MException_her class, which is deserializable.
%             if ~isstruct(struc)
%                 struc_r = struc;
%                 return;
%             end
%             flds = fieldnames(struc);
%             struc_r = struc;
%             for i=1:numel(flds)
%                 if strcmpi(flds{i},'class_name')
%                     if strcmp(struc.class_name,'MException')
%                         struc_r.class_name = 'MException_her';
%                     end
%                 elseif isstruct(struc.(flds{i}))
%                     struc_r.(flds{i}) = FailedMessage.replace_mexc_(struc.(flds{i}));
%                 end
%             end
%             
%         end
    end
    
end


