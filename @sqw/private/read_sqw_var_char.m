function ch=read_sqw_var_char (fid,fmt_ver,isarr)
% Read character array from open binary file
if fmt_ver>=appversion(3.1)
    n=fread(fid,2);
    ch=fread(fid,n,'*char*1');
else
    % Horace file formats prior to '-v3.1'
    if narg==1 || ~isarr
        n=fread_catch(fid,1,'int32');
        ch=fread(fid,[1,n],'*char');
    else
        n=fread_catch(fid,2,'int32');
        ch=fread(fid,n,'*char');
    end
end
