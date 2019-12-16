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
if isempty(scr_path)
    def_wrkr = obj.worker_;
    if strcmp(new_wrkr,def_wrkr)
        cur_fmw = get_or_restore_field(obj,'parallel_framework');
        if ~strcmpi(cur_fmw,'n/a')
            warning('PARALLEL_CONFIG:invalid_argument',...
                ['The script to run in parallel (%s) should be available ',...
                'to all running Matlab sessions but parallel config can not find it.',...
                ' Parallel extensions are disabled'],...
                new_wrkr)
            config_store.instance().store_config(obj,...
                'parallel_framework','n/a','cluster_config','n/a');
            
        end
    else
        config_store.instance().store_config(obj,'worker',def_wrkr);
        error('PARALLEL_CONFIG:invalid_argument',...
            ['The script to run in parallel (%s) should be available ',...
            'to all running Matlab sessions but parallel config can not find it.',...
            'keeping default worker %s'],...
            new_wrkr,def_wrkr)
        
    end
else % worker function is available.
    config_store.instance().store_config(obj,'worker',new_wrkr);
end

