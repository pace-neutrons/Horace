function write_sqw_var_logical_scalar (fid,fmt_ver,var)
% Write logical scalar to open binary file
if fmt_ver>=appversion(3,1)
    fwrite(fid,double(logical(var)),'float64');
else
    % Horace file formats prior to '-v3.1'
    fwrite(fid,int32(logical(var)),'int32');
end
