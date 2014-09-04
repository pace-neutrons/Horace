function ch=read_sqw_var_char (fid,fmt_ver,isarr)
% Read character string or cell array of strings from open binary file
%
%   >> ch=read_sqw_var_char (fid,fmt_ver)
%   >> ch=read_sqw_var_char (fid,fmt_ver,isarr)
%
% Input:
% ------
%   fid         File identifier
%   fmt_ver     File format (appversion object)
%
% For fmt_ver<=3.0 (ignored for later file format versions because unneccesary)
%   isarr       =false if single character string [default]
%               =true  if (2d) character array
%
% Output:
% -------
%   ch          Character string, or cell array of strings

if fmt_ver>=appversion(3.1)
    n=fread(fid,[1,2],'float64');
    if n(1)==1
        ch=strtrim(fread(fid,n,'*char*1'));
    else
        ch=cellstr(fread(fid,n,'*char*1'));
    end
else
    % Horace file formats prior to '-v3.1'
    if nargin==2 || ~isarr
        n=fread(fid,1,'int32');
        ch=fread(fid,[1,n],'*char');
    else
        n=fread(fid,[1,2],'int32');
        ch=cellstr(fread(fid,n,'*char'));
    end
end
