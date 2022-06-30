classdef MatlabMPIWrapper < handle
    % Class wrapps around Matlab MPI methods provided by Matlab parallel
    % computing toolbox and returns the results of these methods
    % in production mode.
    %
    % In test mode it builds fake MPI cluster and mirrors  messages sent
    % to pseudo-mpi neighboring nodes back to the sender node.
    %
    properties(Dependent)
        % if true the wrapper works in test mode, i.e. not sending any
        % messages to
        is_tested;
        
        % return the inted of the lab
        labIndex
        
        % number of parallel workers
        numLabs
        % Test properties.
        %-------------------------------------------------------
        % number of test messages in test cache in test mode. 0 if running
        % in production mode
        n_test_messages
        % test property, providing logging filehandle if the class is
        % initialized in the logging mode
        log_fh
    end
    properties(Access=protected,Hidden=true)
        is_tested_ = false;
        
        labindex_ = 1;
        numlabs_  = 1;
        % Variables for logging the MPI results
        do_logging_ = false; % disable/enable logging for MPI operations,
        % used for debug purposes
        log_fh_ = []; % handle for log file in test mode
        cl_fh_ = [];  % handle for the class to close log file when job is completed
        % shift all tags used by framework by this number to avoid negative
        % tags
        matalb_tag_shift_=10;
        % the tag of the channel to transmit interrupt messages
        interrupt_chan_tag_;
    end
    %
    properties(Access=private)
        % the variable, used as the cache for mirrored messages in test
        % mode.
        messages_cache_ = containers.Map('KeyType','double',...
            'ValueType','any')
    end
    
    methods
        %
        function obj = MatlabMPIWrapper(intrpt_chnl,is_tested,labNum,NumLabs)
            % The constructor of the wrapper around Matlab MPI operations
            %
            % in production mode -- the constructor provides access to
            % Matlab MPI operations
            %
            % Inputs:
            % intrpt_chnl      -- the tag of the channel interrupts are
            %                      distributed through
            %
            % In test mode, additional parameters are needed:
            %
            % is_tested -- if true, the script is being tested rather then
            %              interfacing real MPI and two following
            %              parameters have to be provided.
            % labNum    -- pseudo-number of current parallel lab(worker)
            % NumLabs   -- total (pseudo)number of parallel workers
            %              "participating" in parallel pool.
            obj.interrupt_chan_tag_ = intrpt_chnl;
            
            if ~exist('is_tested', 'var')
                obj.is_tested_ = false;
            else
                obj.is_tested_ = logical(is_tested);
                obj.messages_cache_ = containers.Map('KeyType','double',...
                    'ValueType','any');
                
            end
            if obj.is_tested
                obj.labindex_ = labNum;
                obj.numlabs_  = NumLabs;
            end
            if obj.do_logging_
                pc = parallel_config;
                cf = pc.config_folder;
                f_name = sprintf('MPI_log_Node%d_of_%d.log',obj.labIndex,obj.numLabs);
                obj.log_fh_ = fopen(fullfile(cf,f_name),'w');
                obj.cl_fh_ = onCleanup(@()fclose(obj.log_fh_));
            end
        end
        %
        function mlabSend(obj,message,targ_id)
            % wrapper around Matlab labSend operation.
            % Inputs:
            % message - instance of aMessage class, or the name of (simple)
            %           message to send
            % targ_id - the address of a parallel worker to send message
            %           to.
            %In test mode stores the information in the appropriate lab's
            %buffer.
            % Non-blocking or pretends to be non-blocking.
            %
            if targ_id<1 || targ_id > obj.numLabs
                error('MESSAGES_FRAMEWORK:invalid_argument',...
                    'The message is directed to %d but can be only sent to workers in range [1:%d]',...
                    targ_id,obj.numLabs);
                
            end
            
            if isa(message,'aMessage')
                mess_tag = message.tag;
            elseif ischar(message)
                message = MESS_NAMES.instance().get_mess_class(message);
                mess_tag= message.tag;
            end
            if message.is_persistent
                mess_tag = obj.interrupt_chan_tag_;
            end
            if obj.do_logging_
                fprintf(obj.log_fh_,'***Send-> message: "%s" to lab "%d"\n',...
                    message.mess_name,targ_id);
            end
            
            if obj.is_tested
                push_message_(obj,message,targ_id,mess_tag);
            else
                matlab_tag = mess_tag + obj.matalb_tag_shift_;
                labSend(message,targ_id,matlab_tag);
            end
        end
        %
        function [mess_names,tid_from]=mlabProbe(obj,targ_id,mess_tag)
            % Wrapper around Matlab labProbe command.
            % Checks if specific message is available on the system
            %
            % Inputs:
            % targ_id  - the address of lab to ask for information
            %            if empty, or all -- any task_id
            % mess_tag - if not emtpy, check for specific message tag
            %
            % Returns:
            % mess_names  - cellarray of message names, ready for receiving
            %
            % tid_from    - the index of the lab where where the data are present
            %
            
            if nargin<3
                mess_tag = -1;
            end
            
            if isempty(mess_tag) || (ischar(mess_tag) && strcmp(mess_tag,'any'))
                mess_tag = -1;
            end
            if nargin<2
                error('MESSAGES_FRAMEWORK:invalid_argument',...
                    'Requesting probe from undefined lab')
                
                %targ_id = [];
            end
            if obj.do_logging_
                if isempty(targ_id)
                    lab_name = 'all';
                else
                    lab_name = num2str(targ_id);
                end
                mess_name = MESS_NAMES.mess_name(mess_tag,obj.interrupt_chan_tag_);
                fprintf(obj.log_fh_,'***  probing  Lab: "%s" for mess: "%s"\n',...
                    lab_name,mess_name);
            end
            
            [tags_present,tid_from]= labProbe_(obj,targ_id,mess_tag);
            if isempty(tags_present)
                mess_names = {};
            else
                mess_names = MESS_NAMES.mess_name(tags_present,obj.interrupt_chan_tag_);
            end
            if ~iscell(mess_names )
                mess_names  = {mess_names};
            end
            
            if obj.do_logging_
                if ~isempty(tags_present)
                    fprintf(obj.log_fh_,'***  data present ******:\n');
                    for i=1:numel(mess_names)
                        lab_name = num2str(tid_from(i));
                        fprintf(obj.log_fh_,'     Source: "%s", tag: "%s"\n',...
                            lab_name,mess_names{i});
                    end
                else
                    fprintf(obj.log_fh_,'*** got nothing\n');
                end
            end
            
        end
        %
        
        function [message,varargout]=mlabReceive(obj,lab_id,mess_tag,is_blocking)
            % wrapper around Matlab labReceive operation.
            % Inputs:
            % lab_id   - the number of the lab to ask the information from
            % mess_tag - the tag of the information to ask for. if it is
            %            empty, any type of information is requested.
            % Returns:
            % message   -- the instance of aMessage class, containing the
            %              requested information
            
            % if the message tag corresponds to blocking message,
            % in production mode: Blocks until correspondent message has
            %               been sent, in testing -- throws if the message
            %               has not been issued.
            % if the message is unblocking -- returns empty message if
            %               message has not been issued/delivered
            
            if nargin<3
                mess_tag = -1;
            end
            if isempty(mess_tag)
                mess_tag = -1;
            end
            if iscell(mess_tag) || ischar(mess_tag)
                mess_tag = MESS_NAMES.mess_id(mess_tag,obj.interrupt_chan_tag_);
            end
            if nargin<2
                lab_id = [];
            end
            if ~exist('is_blocking', 'var') % occurs only in testing
                if mess_tag ~= obj.interrupt_chan_tag_
                    is_blocking = MESS_NAMES.is_blocking(mess_tag);
                else
                    is_blocking = false;
                end
            end
            if obj.do_logging_
                if isempty(lab_id)
                    lab_name = 'any';
                else
                    lab_name = num2str(lab_id);
                end
                if is_blocking
                    how = 'synch';
                else
                    how = 'asynch';
                end
                mess_name = MESS_NAMES.mess_name(mess_tag,obj.interrupt_chan_tag_);
                fprintf(obj.log_fh_,'***%s asking to receive from Lab: "%s" Mess:  "%s"\n',...
                    how,lab_name,mess_name);
            end
            [message,tag] = labReceive_(obj,lab_id,mess_tag,is_blocking);
            if ~isempty(message) && ~(message.is_blocking||message.is_persistent)
                % receive and collapse all non-blocking messages with the same tag
                mess = message;
                tag = mess.tag;
                while ~isempty(mess)
                    message = mess;
                    mess = labReceive_(obj,lab_id,tag,false);
                end
            end
            if nargout>1
                varargout{1} = tag;
            end
            if nargout>2
                varargout{2} = lab_id;
            end
            if obj.do_logging_
                if isempty(message)
                    mess_name = '(nothing)';
                else
                    mess_name = message.mess_name;
                end
                source_name = num2str(lab_id);
                fprintf(obj.log_fh_,...
                    '            Message: "%s" Received from source "%s"\n',...
                    mess_name,source_name);
            end
            
        end
        %
        function mlabBarrier(obj)
            % wrapper around Matlab labBarrier command.
            %
            % Stops lab execution until all labs reached the barrier.
            % Ignored in test mode.
            if obj.do_logging_
                fprintf(obj.log_fh_,'*** Arriving at barrier for node %d\n',...
                    obj.labIndex);
            end
            if obj.is_tested
                return; % no barrier should be encountered in test mode
                %       (single threaded test)
            end
            labBarrier();
            if obj.do_logging_
                fprintf(obj.log_fh_,'*** Leaving barrier for node %d\n',...
                    obj.labIndex);
            end
            
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
        function ntm = get.n_test_messages(obj)
            %
            ntm = double(obj.messages_cache_.Count);
        end
        % -------------------------------------------------------------
        % test methods:
        function set_labIndex(obj,num)
            % change labNumber (for testing purposes)
            obj.labindex_ = num;
        end
        function delete(obj)
            obj.messages_cache_ = [];
        end
        function fh = get.log_fh(obj)
            do = obj.do_logging_;
            if do
                fh = obj.log_fh_;
            else
                fh = [];
            end
        end
    end
end
