classdef MatlabMPIWrapper < handle
    % Class wrapps around Matlab MPI methods of Matlab parallel computing toolbox
    % and returns the results of the communication methods in production mode
    % or mirrors messages sent to pseudo-in test mode.
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
    properties(Access=protected,Hidden=true)
        is_tested_ = false;
        labindex_ = 1;
        numlabs_  = 1;
    end
    properties(Access=private)
        % the variable, used as the cache for mirrored messages in test
        % mode.
        messages_cache_ = containers.Map('KeyType','double',...
            'ValueType','any')
    end
    
    methods
        %
        function obj = MatlabMPIWrapper(is_tested,labNum,NumLabs)
            % The constructor of the wrapper around Matlab MPI operations
            %
            % in production mode -- empty constructor provides access to
            % Matlab MPI operations
            % In test mode:
            % is_tested -- true and two other parameters need to be
            %              provided.
            % labNum    -- pseudo-number of current parallel lab(worker)
            % NumLabs   -- total (pseudo)number of parallel workers
            %              "participating" in parallel pool.
            if ~exist('is_tested','var')
                obj.is_tested_ = false;
            else
                obj.is_tested_ = logical(is_tested);
            end
            if obj.is_tested
                obj.labindex_ = labNum;
                obj.numlabs_  = NumLabs;
            end
        end
        %
        function labSend(obj,message,targ_id)
            % wrapper around labSend operation.
            % Inputs:
            % message - instance of aMessage class, or the name of (simple)
            %           message to send
            % targ_id - the address of a parallel worker to send message
            %           to.
            %In test mode stores the information in the appropriate lab's
            %buffer.
            % Non-blocking or pretends to be non-blocking.
            %
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
        %
        function [present,tag_present,source]=labProbe(obj,task_id,mess_tag)
            % Wrapper around Matlab labProbe command.
            % Checks if specific message is available on the system
            %
            % Inputs:
            % task_id  - the address of lab to ask for information
            %            if empty, any task_id
            % mess_tag - if not emtpy, check for specific message tag
            % Returns:
            % present  - true if requested information is available
            %tag_present - the tag of the present information block or
            %            empty if present is false
            % source   - in most cases equal to task id, but if any task
            %            id, the information on where the data are present
            %
            source = task_id;
            if obj.is_tested
                if isempty(task_id)
                    if obj.messages_cache_.Count==0
                        present = false;
                        tag_present = [];
                        return
                    end
                    kk = obj.messages_cache_.keys;
                    present = true;
                    tag_present = zeros(1,numel(kk));
                    source      = zeros(1,numel(kk));
                    for i=1:numel(kk)
                        cont = obj.messages_cache_(kk{i});
                        mess_cont = cont{1};
                        source(i) = kk{i};
                        tag_present(i) = mess_cont.tag;
                    end
                else
                    if isKey(obj.messages_cache_,task_id)
                        present = true;
                        cont = obj.messages_cache_(task_id);
                        mess_cont = cont{1};
                        tag_present = mess_cont.tag;
                        if ~isempty(mess_tag)
                            if tag_present == mess_tag
                                return;
                            else
                                present = false;
                                tag_present  = [];
                            end
                        end
                    else
                        present = false;
                        tag_present = [];
                    end
                end
            else
                if isempty(task_id)
                    [present,source,tag_present] = labProbe;
                else
                    if isempty(mess_tag)
                        [present,~,tag_present] = labProbe(task_id);
                    else
                        present = labProbe(task_id,mess_tag);
                        if present
                            tag_present = mess_tag;
                        else
                            tag_present  = [];
                        end
                    end
                end
            end
        end
        %
        function [message,varargout]=labReceive(obj,targ_id,mess_tag)
            % wrapper around Matlab labReceive operation.
            % Inputs:
            % targ_id  - the number of the lab to ask the information from
            % mess_tag - the tag of the information to ask for. if it is
            %            empty, any type of information is requested.
            % Returns:
            % message   -- the instance of aMessage class, containing the
            %              requested information
            %
            % in production mode: Blocks until correspondent
            if obj.is_tested
                [message,tag] = obj.pop_message_(targ_id,mess_tag);
                id = targ_id;
            else
                if isempty(targ_id)
                    [message,id,tag] = labReceive;
                elseif isempty(mess_tag)
                    message = labReceive(targ_id);
                else % nargin == 3 or more
                    message = labReceive(targ_id,mess_tag);
                end
            end
            if nargout>1
                varargout{1} = id;
            elseif nargout>2
                varargout{2} = tag;
            end
            
        end
        %
        function labBarrier(obj)
            % wrapper around Matlab labBarrier command.
            %
            % Stops lab execution until all labs reached the barrier.
            % Ignored in test mode.
            if obj.is_tested
                return; % no barrier should be encountered in test mode
                %       (single threaded test)
            end
            labBarrier();
        end
        %
        function li = get.labIndex(obj)
            % wrapper around Matlab labindex command.
            %
            % Returns the number of the parallel lab, which executes
            % current parallel task
            if obj.is_tested_
                li = obj.labindex_;
            else
                li = labindex();
            end
        end
        %
        function nl = get.numLabs(obj)
            % wrapper around Matlab numlabs command.
            %
            % Number of parallel labs participating in parallel pool
            if obj.is_tested_
                nl = obj.numlabs_;
            else
                nl = numlabs();
            end
        end
        %
        function is = get.is_tested(obj)
            % getter for is_tested property. True if object is in test mode
            % tested and no real MPI operations can/should be performed.
            %
            %
            is = obj.is_tested_;
        end
        % -------------------------------------------------------------
        % test methods:
        function set_labIndex(obj,num)
            % change labNumber (for testing purposes)
            obj.labindex_ = num;
        end
    end
    methods(Access=private)
        %
        function push_message_(obj,message,target_id,mess_tag)
            % store message intended for the lab specified in the message
            % cache.
            % Input:
            % message -- instance of aMessage class to send
            % target_id - the number of lab to send message to.
            % mess_tag -- the tag indicating the message type.
            %             (duplicate of the tag field of the message,
            %             provided for interface completenes)
            if isKey(obj.messages_cache_,target_id)
                cont = obj.messages_cache_(target_id);
                cont{end+1} = struct('tag',mess_tag,'mess',message.saveobj());
                obj.messages_cache_(target_id) = cont;
            else
                obj.messages_cache_(target_id) = {struct('tag',mess_tag,'mess',message.saveobj())};
            end
        end
        %
        function [message,tag_rec] = pop_message_(obj,target_id,varargin)
            % Restore requested message from the message cache, if it is
            % there, or throw error, if the message is not available
            %
            % Inputs:
            % target_id -- the fake labNum to check for message
            % varargin{1} -- if present, the message tag to check message
            %                for. Empty if any tag is suitable
            % Returns:
            % message -- the instance of aMessage class, presumablu
            %            returned from the target
            % tag_rec -- the tag of the received message (duplicates the
            %            message class information but provided for
            %            consistency.
            if isKey(obj.messages_cache_,target_id)
                cont = obj.messages_cache_(target_id);
                info = cont{1};
                tag_rec = info.tag;
                message = info.mess;
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

