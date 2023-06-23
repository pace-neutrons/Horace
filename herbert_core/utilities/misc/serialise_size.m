function size = serial_size(a)
% The function calculate size of a Matlab data object in case the object
% gets serialized
% Input:
% a -- any type of Matlab object, standard or custom
%
% Returns:
% size  -- the size of the object in bytes

[use_mex,fm] = config_store.instance().get_value('hor_config',...
    'use_mex','force_mex_if_use_mex');
% Temporary disabled mex, #394
use_mex = false;
if use_mex
    try
        size = c_serial_size(a);
        return
    catch ME
        if fm
            rethrow(ME);
        else
            warning(ME.identifier,'%s',ME.message);
        end
    end
end

size = hlp_serial_sise(a);
