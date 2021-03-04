classdef mess_cache < handle
    %class provides persistent storage for messages, received
    % asynchronously and may be requested in the subsequent read operations
    %
    % Assumed only one message of any kind per lab and any subsequent
    % message from a lab overwrites all previous messages, received from this
    % lab.
    properties(Dependent)
        % a handle for worker-specific text log file used for debugging
        % purposes. When the property is accessed first time, the file is
        % opened and is closed when the class is destroyed in the worker.
        log_file_h
    end
    
    properties(Access=private)
        cache_
        log_file_h_ = []
    end
    
    
    methods
        function obj = mess_cache(num_labs)
            if ~exist('num_labs', 'var')
                num_labs = 1;
            end
            obj.init(num_labs);
        end
        %
        function init(obj,num_labs)
            keys = 1;
            val   = cell(1,1);
            obj.cache_ = containers.Map(keys,val,'UniformValues',false);
            remove(obj.cache_,{1});
        end
        
        function push_messages(obj,task_ids,mess)
            % place message into messages cache
            %
            if ~iscell(mess)
                mess = {mess};
            end
            for i=1:numel(task_ids)
                obj.cache_(task_ids(i)) = mess{i};
            end
        end
        %
        function is = is_empty(obj,tid)
            % check if the cache place for the particular task is empty.
            if numel(tid)> 1 && ~iscell(tid)
                tid = num2cell(tid);
            end
            is = ~isKey(obj.cache_,tid);
        end
        %
        function [mess_list,task_ids] = pop_messages(obj,tid_requested,mess_name)
            % return list of the requested messages and delete returned
            % messages from the cache.
            
            if ~exist('tid_requested', 'var') || isempty(tid_requested)...
                    || strcmp(tid_requested,'all')
                tid_requested = 1:obj.cache_.Count;
            end
            if ~exist('mess_name', 'var')
                mess_name = 'any';
            end
            if strcmp(mess_name,'any')
                choose_by_name = false;
            else
                choose_by_name = true;
            end
            %
            all_keys = obj.cache_.keys;
            if isempty(all_keys)
                mess_list = {};
                task_ids = [];
                return;
            end
            all_keys = [all_keys{:}];
            is_requested = ismember(all_keys,tid_requested);
            task_ids = all_keys(is_requested);
            
            [mess_list,selected] = arrayfun(...
                @(x)(mess_selector(obj,x,mess_name,choose_by_name,false)),...
                task_ids,'UniformOutput',false);
            selected = [selected{:}];
            task_ids = task_ids(selected);
            mess_list = mess_list(selected);
            if ~isempty(task_ids )
                remove(obj.cache_,num2cell(task_ids));
            end
            
        end
        %
        function [mess_names_list,tid_received] = probe_all(obj,tid_requested,mess_name)
            % check if the messages from the labs with the name specified are present in
            % the cache.
            % if message name is provided, and is not 'any', only messages
            % names,
            % with the name equal to the name specified are returned.
            if ~exist('tid_requested', 'var') || isempty(tid_requested)...
                    || strcmp(tid_requested,'all')
                tid_requested = 1:obj.cache_.Count;
            end
            if ~exist('mess_name', 'var')
                mess_name = 'any';
            end
            if strcmp(mess_name,'any')
                choose_by_name = false;
            else
                choose_by_name = true;
            end
            %
            all_keys = obj.cache_.keys;
            is_requested = ismember(all_mess,tid_requested);
            task_ids = all_keys(is_requested);
            
            [mess_names_list,selected] = arrayfun(...
                @(x)(mess_selector(obj,x,mess_name,choose_by_name,true)),...
                task_ids,'UniformOutput',false);
            selected = [selected{:}];
            tid_received = task_ids(selected);
            mess_names_list = mess_names_list(selected);
            
        end
        %
        %         function sz = get.cache_capacity(obj)
        %             sz = obj.cache_capacity_;
        %         end
        %
        %
        function clear(obj)
            % clear cache contents without changing the cache capacity
            %
            keys = obj.cache_.keys;
            remove(obj.cache_,keys);
        end
        %
        function fh = get.log_file_h(obj)
            if isempty(obj.log_file_h_)
                fn = sprintf('Log_file_worker%d.txt',labindex);
                obj.log_file_h_ = fopen(fn,'w');
            end
            fh = obj.log_file_h_;
        end
        %
        function delete(obj)
            if ~isempty(obj.log_file_h_ )
                fclose(obj.log_file_h_ );
                obj.log_file_h_  = [];
            end
            obj.init(1);
        end
    end
    methods(Access=private)
        function [mess,is_selected]= mess_selector(obj,tid,mess_name,choose_by_name,get_name)
            % select message from cache according to the selection criteria
            %
            mess = obj.cache_(tid);
            the_name = mess.mess_name;
            if choose_by_name
                if strcmp(the_name,mess_name)
                    is_selected = true;
                else
                    is_selected = false;
                end
            else
                is_selected = true;
            end
            if get_name
                mess = the_name;
            end
        end
        
    end
end

