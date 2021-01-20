%Wrapper to handle mex/nomex

function ser = serialise(a)
    if use_mex
        ser = c_serialise(a)
    else
        ser = hlp_serialise(a)
    end
end