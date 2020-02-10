function fname=make_filename(in_dir,str)
% function makes full filename from file path and filename and verifies, if
% such file exists
%
%   $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
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

