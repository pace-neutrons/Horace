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
        function [present,tag_present,source]=mlabProbe(obj,task_id,mess_tag)
            % Wrapper around Matlab labProbe command.
            % Checks if specific message is available on the system
            %
            % Inputs:
            % task_id  - the address of lab to ask for information
            %            if empty, any task_id
            % mess_tag - if not emtpy, check for specific message tag
            % Returns:
            % present  - true if requested information is available
            % tag_present - the tag of the present information block or
            %            empty if present is false
            % source   - in most cases equal to task id, but if any task
            %            id, the information on where the data are present
            %

            if ~exist('mess_tag','var') 
                mess_tag = -1;
            end
            if isempty(mess_tag)
                mess_tag = -1;
            end
            if ~exist('task_id','var')
                task_id = [];
            end
            
            [present,tag_present,source]= labProbe_(obj,task_id,mess_tag);
        end
        %
        function [message,varargout]=mlabReceive(obj,targ_id,mess_tag)
            % wrapper around Matlab labReceive operation.
            % Inputs:
            % targ_id  - the number of the lab to ask the information from
            % mess_tag - the tag of the information to ask for. if it is
            %            empty, any type of information is requested.
            % Returns:
            % message   -- the instance of aMessage class, containing the
            %              requested information
            %
            % in production mode: Blocks until correspondent message has
            %               been sent
            if ~exist('mess_tag','var') 
                mess_tag = -1;
            end
            if isempty(mess_tag)
                mess_tag = -1;
            end
            if ~exist('targ_id','var')
                targ_id = [];
            end
            [message,tag,source] = labReceive_(obj,targ_id,mess_tag);            
            if nargout>1
                varargout{1} = tag;
            end
            if nargout>2
                varargout{2} = source;
            end
            
        end
        %
        function mlabBarrier(obj)
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
end
