function write_sqw_var_char (fid,fmt_ver,ch)
% Write character array to open binary file
if fmt_ver>=appversion(3.1)
    n=size(ch);
    fwrite(fid,n);  % write length of string
    fwrite(fid,ch,'char*1');
else
    % Horace file formats prior to '-v3.1'
    if size(ch,1)==1 || isempty(ch)     % character string (or 1x0 or 0x0 array)
        n=numel(ch);
    else
        n=size(ch);
    end
    fwrite(fid,n,'int32');
    fwrite(fid,ch,'char');
end
