function ser = serialize(a)
%Wrapper to handle mex/nomex
[use_mex,fm] = config_store.instance().get_value('hor_config',...
    'use_mex','force_mex_if_use_mex');

% counter for number of issued warnings
persistent wc;

if use_mex
    try
        ser = c_serialize(a);
        return
    catch ME
        if fm
            rethrow(ME);
        else
            % restrict number of warning to 50 per session not to constantly
            % pester users with the same information again and again.
            if isempty(wc) || wc > 50
                wc = 0;
                warning(ME.identifier,'%s',ME.message);
            end
            wc = wc+1;
        end
    end
end
ser = hlp_serialize(a);
