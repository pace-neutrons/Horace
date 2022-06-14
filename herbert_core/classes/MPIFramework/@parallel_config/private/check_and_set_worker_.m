function obj = check_and_set_worker_(obj,new_wrkr)
% Check and set new worker:
% Input:
% new_wrkr - the string, defining new worker function.
%
if ~ischar(new_wrkr)
    error('PARALLEL_CONFIG:invalid_argument',...
        'The worker property needs the executable script name')
end
scr_path = which(new_wrkr);
config_instance = config_store.instance();
if isempty(scr_path)
    % Check if it is a compiled worker
    compiled_wrkr = check_compiled_(new_wrkr);
    if ~isempty(compiled_wrkr)
        config_instance.store_config(obj, 'worker', new_wrkr);
        config_instance.store_config(obj, 'is_compiled', true);
        return
    end

    def_wrkr = obj.worker_;
    if strcmp(new_wrkr,def_wrkr)
        cur_fmw = get_or_restore_field(obj,'parallel_cluster');
        if ~strcmpi(cur_fmw,'none')
            warning('PARALLEL_CONFIG:invalid_argument',...
                ['The script to run in parallel (%s) should be available ',...
                'to all running Matlab sessions but parallel config can not find it.',...
                ' Parallel extensions are disabled'],...
                new_wrkr)
            config_instance.store_config(obj,...
                'parallel_cluster','none','cluster_config','none');
            
        end
    else
        config_instance.store_config(obj,'worker',def_wrkr);
        error('PARALLEL_CONFIG:invalid_argument',...
            ['The script to run in parallel (%s) should be available ',...
            'to all running Matlab sessions but parallel config can not find it.',...
            'keeping default worker %s'],...
            new_wrkr,def_wrkr)
        
    end
else % worker function is available.
    config_instance.store_config(obj, 'worker', new_wrkr);
    config_instance.store_config(obj, 'is_compiled', false);
end
end % function

function out = check_compiled_(worker)
    out = '';
    if is_file(worker) && ~endsWith(worker, '.m')
        % Assume if input is full path to file, then it is a compiled worker
        out = worker;
    else
        if ispc()
            cmd = 'where';
        else
            cmd = 'which';
        end
        [rs, rv] = system([cmd ' ' worker]);
        if rs == 0
            % Assume if it is on the system path, then it is a compiled worker
            out = splitlines(strip(rv));
            out = out{1}; % Only take first path if there is more than one
        end
    end
end
