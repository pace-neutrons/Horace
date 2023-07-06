function [ok,file_exist,file_name,err_mess] = check_file_writable(input_file,require_existance)
% Verify the input file name, convert it into standard format, and check if is is writable
%
% Input:
% input_file -- input file with the path. If path is not provided, the
%               working directory is assumed as target directory
% require_existance -- if true, return if the file is not found.
%                      default -- false
% Outputs:
% ok         -- if true, all file checks are successful.
% file_exist -- true if file exist and false otherwise
% file_name  -- the name of the file with full standard path, leading to
%               it.
% err_mess   -- the string, containing the reason for failure if ok== false
%
if ~exist('require_existance', 'var')
    require_existance = false;
end
err_mess = '';
ok = true;

tf=is_string(input_file);

if tf && ~isempty(strtrim(input_file))
    file_name=strtrim(input_file);
else
    ok=false; err_mess='sqw file name must be a non-empty string'; return
end
[file_name,file_exist] = resolve_path(file_name);

% Checks for file can be written
if ~file_exist
    file_exist=false;
    if require_existance
        ok=false; err_mess=sprintf('sqw file: "%s"  does not exist',file_name); return
    end
    file_path=fileparts(file_name);
    if ~isempty(file_path) && ~is_folder(file_path)
        ok=false;
        err_mess=sprintf('The folder "%s" to place the file do not exist',file_path);
        return
    end
    fh = fopen(file_name,'w');
    if fh>0
        fclose(fh);
        delete(file_name);
    else
        ok = false; err_mess= sprintf('Cannot open file: "%s" for writing',file_name'); return
    end
else
    file_exist=true;
end