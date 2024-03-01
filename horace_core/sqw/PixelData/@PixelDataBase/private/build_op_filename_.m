function [filename,move_to_orig] = build_op_filename_(original_fn,target_fn)
%BUILD_OP_FILENAME_ builds filename - target of an operation.
%
% When an operation performed on filebacked object, its temporary
% results are stored in a temporary file. The name of this file is build
% according to the rules defined here.  See PageOpBase
% for more information about operations.
%
% Inputs:
% original_fn -- name of the orignal file-source of the
%                operation
% target_fn   -- optional full (with path) name of the file to save data in
%                if path is missing, working directory assumed.
%
% Returns:
% filename     -- target filename for operation.
% move_to_orig -- true, if original filename was equal to
%                 target filename and we need to move resulting
%                 file to the initial location as the result of
%                 operation. False otherwise.

if isempty(target_fn)
    if isempty(original_fn)
        fn_base = 'in_mem';
    else
        fn_base = original_fn;
    end
    move_to_orig = false;

    filename = build_tmp_file_name(fn_base);
else
    [filepath,fn_base,fext] = fileparts(target_fn);
    if isempty(filepath)
        filepath = pwd;
    end
    fext_is_tmp = strncmp(fext,'.tmp',4);
    % if we want to write to the same file, need to modify file handler to
    % work with tmp file anyway
    if strcmp(original_fn,target_fn)
        move_to_orig = true;
        if fext_is_tmp
            filename = target_fn;
        else
            filename = build_tmp_file_name(fn_base,filepath);
        end
    else
        move_to_orig = false;
        filename     = target_fn;
    end
end
