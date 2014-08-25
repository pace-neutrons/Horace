function var = read_sqw_var_logical_scalar (fid,fmt_ver)
% Read logical scalar from open binary file
if fmt_ver>=appversion(3.1)
    var=logical(fread(fid,1),'float64');
else
    % Horace file formats prior to '-v3.1'
    var=logical(fread(fid,1,'int32'));
end
