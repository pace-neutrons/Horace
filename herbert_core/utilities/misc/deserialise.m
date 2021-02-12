function ser = deserialise(a)
%Wrapper to handle mex/nomex
%
[use_mex,fm] = config_store.instance().get_value('herbert_config',...
    'use_mex','force_mex_if_use_mex');
if use_mex
    try
        ser = c_deserialise(a);
        return
    catch ME
        if fm
            rethrow(ME);
        else
            warning(ME.identifier,'%s',ME.message);
            use_mex = false;
        end
    end
end
if ~use_mex
    ser = hlp_deserialise(a);
end
