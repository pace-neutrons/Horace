%Wrapper to handle mex/nomex

function ser = deserialise(a)
    if get(herbert_config,'use_mex')
        ser = c_deserialise(a);
    else
        ser = hlp_deserialise(a);
    end
end