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
    end
    properties(Access=protected,Hidden=true)
        is_tested_ = false;
        labindex_ = 1;
        numlabs_  = 1;
        % Variables for logging the MPI results
        do_logging_ = false; % disable/enable logging for MPI operations
        log_fh_ = [];
        cl_fh_ = [];
        % shift all tags used by framework by this number to avoid negative
        % tags
        matalb_tag_shift_=10;
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
            if obj.do_logging_
                fprintf(obj.log_fh_,'***Send-> message: %s to lab %d\n',...
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
            if isempty(mess_tag)
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
                fprintf(obj.log_fh_,'***  probing  Lab: %s for tag %d\n',...
                    lab_name,mess_tag);
            end
            
            [tags_present,tid_from]= labProbe_(obj,targ_id,mess_tag);
            if isempty(tags_present)
                mess_names = {};
            else
                mess_names = MESS_NAMES.mess_name(tags_present);
            end
            if ~iscell(mess_names )
                mess_names  = {mess_names};
            end
            
            if obj.do_logging_
                if ~is_empty(tags_present)
                    fprintf(obj.log_fh_,'***  data present ******\n');
                    for i=1:numel(mess_names)
                        lab_name = num2str(tid_from);
                        fprintf(obj.log_fh_,'     Source: %s, tag(s) %s\n',...
                            lab_name,mess_names{i});
                    end
                else
                    fprintf(obj.log_fh_,'*** got nothing\n');
                end
            end
            
        end
        %
        function [message,varargout]=mlabReceive(obj,targ_id,mess_tag,is_blocking)
            % wrapper around Matlab labReceive operation.
            % Inputs:
            % targ_id  - the number of the lab to ask the information from
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
            if nargin<2
                targ_id = [];
            end
            if obj.do_logging_
                if isempty(targ_id)
                    lab_name = 'any';
                else
                    lab_name = num2str(targ_id);
                end
                fprintf(obj.log_fh_,'***receving from Lab: %s Mess tag %d\n',...
                    lab_name,targ_id);
            end
            if ~exist('is_blocking','var')
                is_blocking = MESS_NAMES.is_blocking(mess_tag);
            end
            [message,tag,source] = labReceive_(obj,targ_id,mess_tag,is_blocking);
            if nargout>1
                varargout{1} = tag;
            end
            if nargout>2
                varargout{2} = source;
            end
            if obj.do_logging_
                tag_name = num2str(tag);
                source_name = num2str(source);
                fprintf(obj.log_fh_,...
                    '            Message with tag %s Received from source %s\n',...
                    tag_name,source_name);
            end
            
        end
        %
        function mlabBarrier(obj)
            % wrapper around Matlab labBarrier command.
            %
            % Stops lab execution until all labs reached the barrier.
            % Ignored in test mode.
            if obj.do_logging_
                fprintf(obj.log_fh_,'*** Ariving at barrier for node %d\n',...
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
        % -------------------------------------------------------------
        % test methods:
        function set_labIndex(obj,num)
            % change labNumber (for testing purposes)
            obj.labindex_ = num;
        end
    end
end
