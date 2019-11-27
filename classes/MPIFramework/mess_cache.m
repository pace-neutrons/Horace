classdef mess_cache < handle
    %class provides persistent storage for messages, received
    % asynchronously and may be requested in the subsequent read operations
    %
    % Assumed only one message of any kind per lab and any subsequent
    % message from a lab overwrites all previous messages, received from this
    % lab.
    properties
        
    end
    properties(Dependent)
        % when the class is initialized, this should be set to the number of
        % workers in the pool.
        cache_capacity
        % a handle for worker-specific text log file used for debugging
        % purposes. When the property is accessed first time, the file is
        % opened and is closed when the class is destroyed in the worker.
        log_file_h
    end
    
    properties(Access=private)
        mess_cache_
        cache_capacity_ = 0;
        log_file_h_ = []
    end
    
    
    methods(Static)
        function obj = instance(varargin)
            persistent cache;
            if nargin>0
                if ischar(varargin{1}) % clear cache holder
                    clear cache;
                    cache = [];
                    return;
                else
                    argi = varargin;
                end
            else
                argi = {};
            end
            if isempty(cache)
                cache = mess_cache(argi{:});
            end
            obj = cache;
        end
    end
    methods
        function push_messages(obj,task_ids,mess)
            if iscell(mess) %list of messages
                if numel(task_ids) ~= numel(mess)
                    error('MESS_cache:invalid_argument',...
                        'size of messages array has to be equal to the size of index array')
                end
                
                if islogical(task_ids)
                    mess = mess(task_ids);
                    task_ids = find(task_ids);
                end
                for i=1:numel(task_ids)
                    obj.push_messages(task_ids(i),mess{i});
                end
            elseif isa(mess,'aMessage') %single message
                if task_ids>obj.cache_capacity_
                    error('MESS_cache:invalid_argument',...
                        'messages cache initialized for %d workers, but attempting to store message from the worker N%d',...
                        obj.cache_capacity_,task_ids);
                end
                mc = obj.mess_cache_{task_ids};
                mc.push(mess);
                obj.mess_cache_{task_ids} = mc;
            else
                error('MESS_cache:invalid_argument',...
                    'input for push messages must be either cellarray of messages or single message')
            end
        end
        %
        function [mess_list,task_ids] = pop_messages(obj,tid_requested,mess_name)
            % return list of the requested messages and delete returned
            % messages from the cache.
            
            if ~exist('tid_requested','var') || isempty(tid_requested)
                task_ids = 1:numel(obj.mess_cache_);
            else
                mess_exist = cellfun(@(x)(x.length ~=0),obj.mess_cache_,'UniformOutput',true);
                ind_exist = find(mess_exist);
                is_requested = ismember(tid_requested,ind_exist);
                task_ids  = tid_requested(is_requested);
            end
            
            if exist('mess_name','var')
                select_by_name = true;
            else
                select_by_name = false;
            end
            
            n_mess_max = numel(task_ids);
            mess_list = cell(n_mess_max,1);
            mess_exist = false(n_mess_max,1);
            for i=1:n_mess_max
                if select_by_name
                    [present,key] = obj.mess_cache_{task_ids(i)}.check(mess_name);
                    if present
                        mess_exist(i) = true;
                        mess_list{i}  = obj.mess_cache_{task_ids(i)}.pop(mess_name,key);
                    end
                else
                    mess_list{i} = obj.mess_cache_{task_ids(i)}.pop();
                    if ~isempty(mess_list{i})
                        mess_exist(i) = true;
                    end
                end
            end
            mess_list = mess_list(mess_exist);
            task_ids  = task_ids(mess_exist);
        end
        %
        function [all_messages,mess_present] = get_cache_messages(obj,tid_requested,mess_name,lock_until_received)
            % Restore old messages, previously stored in the cache in the
            % order, spefified by tid_requested
            %
            % prepare outputs
            n_requested = numel(tid_requested);
            all_messages = cell(n_requested ,1);
            if lock_until_received
                [old_mess,old_tids]= obj.pop_messages(tid_requested,mess_name);
            else
                [old_mess,old_tids]= obj.pop_messages(tid_requested);
            end
            mess_present = ismember(tid_requested,old_tids);
            if any(mess_present)
                
                n_message = 0;
                for i=1:n_requested
                    if mess_present(i)
                        n_message = n_message+1;
                        all_messages{i} = old_mess{n_message};
                    end
                end
            end
            
            
        end
        function sz = get.cache_capacity(obj)
            sz = obj.cache_capacity_;
        end
        function noc = get_n_occupied(obj)
            noc = sum(cellfun(@(x)(x.length~=0),obj.mess_cache_,'UniformOutput',true));
        end
        function clear(obj)
            % clear cache contents without changing the cache capacity
            num_labs= obj.cache_capacity_;
            obj.mess_cache_ = cell(1,num_labs);
            for i=1:num_labs
                obj.mess_cache_{i} = copy(single_tid_mess_queue);
            end
            
        end
        function fh = get.log_file_h(obj)
            if isempty(obj.log_file_h_)
                fn = sprintf('Log_file_worker%d.txt',labindex);
                obj.log_file_h_ = fopen(fn,'w');
            end
            fh = obj.log_file_h_;
        end
        function delete(obj)
            if ~isempty(obj.log_file_h_ )
                fclose(obj.log_file_h_ );
                obj.log_file_h_  = [];
            end
            obj.instance('delete');
        end
    end
    methods(Access = private)
        function obj = mess_cache(num_labs)
            if ~exist('num_labs','var')
                nmp = which('numlabs');
                if isempty(nmp)
                    num_labs = 1;
                else
                    num_labs = numlabs; % MPI numlabs
                end
            end
            obj.mess_cache_ = cell(1,num_labs);
            obj.cache_capacity_ = num_labs;
            for i=1:num_labs
                obj.mess_cache_{i} = copy(single_tid_mess_queue);
            end
            
        end
        
    end
end

