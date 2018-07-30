classdef mess_cash < handle
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
        cash_capacity
        % a handle for worker-specific text log file used for debugging
        % purposes. When the property is accessed first time, the file is
        % opened and is closed when the class is destroyed in the worker.
        log_file_h
    end
    
    properties(Access=private)
        mess_cash_
        cash_capacity_ = 0;
        log_file_h_ = []
    end
    
    
    methods(Static)
        function obj = instance(varargin)
            persistent cash;
            if nargin>0
                if ischar(varargin{1}) % clear cash holder
                    clear cash;
                    cash = [];
                    return;
                else
                    argi = varargin;
                end
            else
                argi = {};
            end
            if isempty(cash)
                cash = mess_cash(argi{:});
            end
            obj = cash;
        end
    end
    methods
        function obj = push_messages(obj,task_ids,mess)
            if iscell(mess) %list of messages
                if numel(task_ids) ~= numel(mess)
                    error('MESS_CASH:invalid_argument',...
                        'size of messages array has to be equal to the size of index array')
                    
                end
                
                if islogical(task_ids)
                    mess = mess(task_ids);
                    task_ids = find(task_ids);
                end
                for i=1:numel(task_ids)
                    mc = obj.mess_cash_(task_ids(i));
                    mc.push(mess{i});
                    obj.mess_cash_(task_ids(i)) = mc;
                end
            elseif isa(mess,'aMessage') %single message
                if task_ids>obj.cash_capacity_
                    error('MESS_CASH:invalid_argument',...
                        'messages cash initialized for %d workers, but attempting to store message from the worker N%d',...
                        obj.cash_capacity_,task_ids);
                end
                mc = obj.mess_cash_(task_ids);
                mc.push(mess);
                obj.mess_cash_(task_ids) = mc;
            else
                error('MESS_CASH:invalid_argument',...
                    'input for push messages must be either cellarray of messages or single message')
            end
        end
        %
        function [mess_list,task_ids] = pop_messages(obj,tid_requested,mess_name)
            % return list of the requested messages and delete returned
            % messages from the cash.
            
            if ~exist('tid_requested','var') || isempty(tid_requested)
                task_ids = 1:numel(obj.mess_cash_);
            else
                mess_exist = arrayfun(@(x)(x.length ~=0),obj.mess_cash_,'UniformOutput',true);
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
                    [present,key] = obj.mess_cash_(task_ids(i)).check(mess_name);
                    if present
                        mess_exist(i) = true;
                        mess_list{i}  = obj.mess_cash_(task_ids(i)).pop(mess_name,key);
                    end
                else
                    mess_list{i} = obj.mess_cash_(task_ids(i)).pop();
                    if ~isempty(mess_list{i})
                        mess_exist(i) = true;
                    end
                end
            end
            mess_list = mess_list(mess_exist);
            task_ids  = task_ids(mess_exist);
        end
        
        %
        function sz = get.cash_capacity(obj)
            sz = obj.cash_capacity_;
        end
        function noc = get_n_occupied(obj)
            noc = sum(arrayfun(@(x)(x.length~=0),obj.mess_cash_,'UniformOutput',true));
        end
        function clear(obj)
            % clear cash contents without changing the cash capacity
            num_labs= obj.cash_capacity_;
            for i=1:num_labs
                obj.mess_cash_(i) = copy(single_tid_mess_queue);                
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
        function obj = mess_cash(num_labs)
            if ~exist('num_labs','var')
                nmp = which('numlabs');
                if isempty(nmp)
                    num_labs = 1;
                else
                    num_labs = numlabs; % MPI numlabs
                end
            end
            obj.mess_cash_ = repmat(single_tid_mess_queue,1,num_labs);
            for i=1:numel(num_labs)
                obj.mess_cash_(i) = copy(single_tid_mess_queue);
            end
            obj.cash_capacity_ = num_labs;
        end
        
    end
end

