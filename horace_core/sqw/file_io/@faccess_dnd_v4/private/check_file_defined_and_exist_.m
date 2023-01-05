function     check_file_defined_and_exist_(obj,io_mode,varargin)
% check if the file, requested for IO operation is defined and exist
% Inputs:
% obj     -- instance of faccess object, which may contain defined file
%            name for the operation
% io_mode -- string describing the mode of operation (read or write). Used
%            for throwing diagnostics error messages only.
% varargin
%         -- list of argument, which may contain filename, overriding
%            filename availiable in obj

% Works only on Matlab 2016b and later.
fname_present = cellfun(@(x)((ischar(x)||isstring(x))&&~startsWith('-')), ...
    varargin);
if any(fname_present)
    file_4_io = varargin{fname_present};
else
    file_4_io = obj.full_filename;
end
if ~is_file(file_4_io)
    if isa(block_name_or_instance,'data_block')
        bln = block_name_or_instance.block_name;
    else
        bln = block_name_or_instance;
    end
    error('HORACE:faccess_dnd_v4:invalid_argument', ...
        'File "%s " to %s block %s is missing. Can not %s block. Incorrect filename?', ...
        file_4_io,io_mode,bln,io_mode)
end

