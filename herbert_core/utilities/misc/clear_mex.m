function clear_mex()
%CLEAR_MEX removes mex files from memory including Horace mex files which
%may be locked there.
try
    bin_pixels_c('clear');
catch
end
try
    cpp_communicator('finalize',0);
catch
end
clear mex;
end