function fname=make_filename(in_dir,str)
% function makes full filename from file path and filename and verifies, if
% such file exists
%
%   $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
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
