classdef mess_cash < handle
    %class provides persistent storage for messages, received
    % assynchroneously and may be requested in the subsequent read operations
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
        % purporses. When the property is accessed first time, the file is
        % opened and is closed when the class is destroyed in the worker.
        log_file_h
    end
    
    properties(Access=private)
        mess_cash_ = {}
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
                obj.mess_cash_(task_ids) = mess(:);
            elseif isa(mess,'aMessage') %single message
                if task_ids>obj.cash_capacity_
                    error('MESS_CASH:invalid_argument',...
                        'messages cash initialized for %d workers, but atteming to store message from the worker N%d',...
                        obj.cash_capacity_,task_ids);
                end
                obj.mess_cash_{task_ids} = mess;
            else
                error('MESS_CASH:invalid_argument',...
                    'input for push messages must be either cellarray of messages or single message')
            end
        end
        %
        function [mess_list,task_ids] = pop_messages(obj,tid_requested,mess_name)
            % return list of the requested messages and delete these
            % messages from the cash.
            mess_exist = cellfun(@(x)~isempty(x),obj.mess_cash_,'UniformOutput',true);
            ind_exist = find(mess_exist);
            if ~exist('tid_requested','var') || isempty(tid_requested)
                task_ids = 1:numel(obj.mess_cash_);
                mess_list= obj.mess_cash_;
            else
                is_requested = ismember(tid_requested,ind_exist);
                task_ids  = tid_requested(is_requested);
                mess_list = obj.mess_cash_(task_ids);
            end
            
            if exist('mess_name','var')
                % if mess_name is provided, remove only the messages with the
                % name requested
                selected = cellfun(...
                    @(x)(~isempty(x) && (strcmp(x.mess_name,mess_name) || strcmp(x.mess_name,'failed'))),...
                    mess_list,'UniformOutput',true);
                mess_list = mess_list(selected);
                task_ids  = task_ids(selected);
            end
            
            % remove selected messages from cash. Fail message is
            % persistent and is never removed. May be overwritten, if other
            % message arrives after "failed".
            mess_exist(task_ids) = false;
            for i=1:numel(obj.mess_cash_)
                if ~mess_exist(i)
                    if ~isempty(obj.mess_cash_{i})
                        if ~(strcmp(obj.mess_cash_{i}.mess_name,'failed'))% || ...
                            %strcmp(obj.mess_cash_{i}.mess_name,'completed') )
                            obj.mess_cash_{i} = [];
                        end
                    end
                end
            end
            
        end
        
        %
        function sz = get.cash_capacity(obj)
            sz = obj.cash_capacity_;
        end
        function noc = get_n_occupied(obj)
            noc = sum(cellfun(@(x)~isempty(x),obj.mess_cash_,'UniformOutput',true));
        end
        function clear(obj)
            % clear cash contents without changing the cash capacity
            obj.mess_cash_ = cell(1,obj.cash_capacity_);
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
                num_labs = numlabs; % MPI numlabs
            end
            obj.mess_cash_ = cell(1,num_labs);
            obj.cash_capacity_ = num_labs;
        end
        
    end
end

