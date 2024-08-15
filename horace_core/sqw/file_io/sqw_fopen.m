function fh = sqw_fopen(file, permissions)
%SQW_FOPEN Function used to open Horace binary sqw file to keep all format
% details of sqw file in one place
% Inputs:
% file        -- name (with full path) to the binary sqw file
% permissions -- the permissions to open the file.
%
% Output:
% fh          -- handle of the file open for binary access with format
%                common to Horace sqw file
% Throws if open operation is unsuccessful
[fp,fn] = fileparts(file);
if ~isfolder(fp)
    [ok,mess] = mkdir(fp);
    if ~ok
        error('HERBERT:utilities:runtime_error', ...        
               ['Folder %s to write file: %s does ' ...
               'not exist and you can not create it because of: %s'], ...
               fp,fn,mess);
    end
end

fh = fopen(file,permissions,'l','Windows-1252');
if fh<1
    error('HERBERT:utilities:runtime_error', ...
        'Can not open file: %s with permissions: %s',file,permissions);
end
