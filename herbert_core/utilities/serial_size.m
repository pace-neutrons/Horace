%Wrapper to handle mex/nomex

function ser = serial_size(a)
    if use_mex
        ser = c_serial_size(a)
    else
        ser = hlp_serial_sise(a)
    end
end