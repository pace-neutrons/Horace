classdef MatlabMPIWrapper < handle
    % Class wrapps around Matlab MPI methods of Matlab parallel computing toolbox
    % and returns the results of the communication methods in production mode
    % or mirrors messages sent to pseudo-in test mode.
    %
    %
    %
    properties(Dependent)
        % if true the wrapper works in test mode, i.e. not sending any
        % messages to
        is_tested;
        % return the inted of the lab
        labIndex
        % number of parallel workers
        numLabs
        
    end
    properties(Access=protected)
        is_tested_ = false;
        labindex_ = 1;
        numlabs_  = 1;
    end
    properties(Access=private)
        % the variable, used as the cache for mirrored messages in test
        % mode.
        messages_cache_ = containers.Map('UniformValues',false)
    end
    
    methods
        function obj = MatlabMPIWrapper(is_tested,labNum,NumLabs)
            if ~exist('is_tested','var')
                obj.is_tested_ = false;
            else
                obj.is_tested = logical(is_tested);
            end
            if obj.is_tested
                obj.labindex_ = labNum;
                obj.numlabs_  = NumLabs;
            end
        end
        function labSend(obj,message,targ_id)
            % wrapper around labSend operation.
            if isa(message,'aMessage')
                mess_tag = message.tag;
            elseif ischar(message)
                message = MESS_NAMES.get_mess_class(message);
                mess_tag= MESS_NAMES.mess_id(message);
            end
            
            if obj.is_tested
                push_message_(obj,message,targ_id,mess_tag);
            else
                labSend(message,targ_id,mess_tag)
            end
        end
        function [message,varargout]=labReceive(obj,message,targ_id,mess_tag)
            % wrapper around labReceive operation.
            if obj.is_tested
                obj.pop_message_(message,targ_id,mess_tag);
            else
                if isempty(targ_id)
                    [message,id,tag] = labReceive;
                    if nargout>1
                        varargout{1} = id;
                    elseif nargout>2
                        varargout{2} = tag;
                    end
                elseif isempty(mess_tag)
                    message = labReceive(targ_id);
                else % nargin == 3 or more
                    message = labReceive(targ_id,mess_tag);
                end
                
                
            end
        end
        
        function labBarrier(obj)
            if obj.is_tested
                return;
            end
            labBarrier();
        end
        function li = get.labIndex(obj)
            if obj.is_tested_
                li = obj.labindex_;
            else
                li = labindex();
            end
        end
        function nl = get.numLabs(obj)
            if obj.is_tested_
                nl = obj.numlabs_;
            else
                nl = numlabs();
            end
        end
        function is = get.is_tested(obj)
            is = obj.is_tested_;
        end
    end
    methods(Access=private)
        function push_message_(obj,message,target_id,mess_tag)
            %
            if isKey(obj.messages_cache_,target_id)
                cont = obj.messages_cache_(target_id);
                cont{end+1} = {mess_tag,message.saveobj()};
                obj.messages_cache_(target_id) = cont;
            else
                obj.messages_cache_(target_id) = {mess_tag,message.saveobj()};
            end
        end
        function [message,tag_rec] = pop_message_(obj,target_id,varargin)
            if isKey(obj.messages_cache_,target_id)
                cont = obj.messages_cache_(target_id);
                info = cont{1};
                tag_rec = info{1};
                message = info{2};
                message = aMessage.loadobj(message);
                if nargin>2
                    tag = varargin{1};
                    if ~(isempty(tag) || strcmp(tag,'any'))
                        if tag ~=tag_rec
                            error('MATLAB_MPI_WRAPPER:runtime_error',...
                                'Attempt to issue blocking receive from lab %d, tag %d Tag present: %d',...
                                target_id,tag,tag_rec )
                        end
                    end
                end
                if numel(cont)>1
                    cont = cont(2:end);
                    obj.messages_cache_(target_id) = cont;
                else
                    remove(obj.messages_cache_,target_id);
                end
            else
                error('MATLAB_MPI_WRAPPER:runtime_error',...
                    'Attempt to issue blocking receive from lab %d',...
                    target_id)
            end
        end
        
    end
end

