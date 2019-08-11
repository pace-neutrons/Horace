function fname=make_filename(in_dir,str)
% function makes full filename from file path and filename and verifies, if
% such file exists
%
%   $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
%

if exist(str,'file')
    fname=str;
    return;
end
[fp,filename,fext] = fileparts(str);
fname=fullfile(in_dir,fp,[filename,fext]);       
if ~exist(fname,'file')
    error('HERBERT_MEX:invalid_argument','file: %s expected to be compiled but does not exist',fname);
end
