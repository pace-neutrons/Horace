function [ser,nbytes] = deserialise(a,pos)
% Function used to deserialize object or array of objects serialized previously into
% the array of bytes using serialize routine.
% Inputs:
% a   -- array of bytes, contaning serialized objects
% pos -- starting position of the data to deserialize. If missing, assumed that data to deserialize
%        are located from the beginning of the input array
% Outputs:
% ser    -- deserialized contencts of the array of bytes
% nbytes -- the extend, deserialized data were occupied in the input array
%
%
if nargin<2
    pos = 1;
end
[use_mex,fm] = config_store.instance().get_value('hor_config',...
    'use_mex','force_mex_if_use_mex');

if use_mex
    try
        [ser,nbytes] = c_deserialise(a,pos);
        return
    catch ME
        if fm
            rethrow(ME);
        else
            warning(ME.identifier,'%s',ME.message);
        end
    end
end

[ser,nbytes] = hlp_deserialise(a,pos);
