function [obj,is_tmp] = activate_(obj,filename,no_tmp_file_setting)
% open file access for file, previously closed by deactivate
% operation, possibly using new file name
%
% filename   -- The name of the file to use as a target file and containing
%               the pixel information
% Optional:
% no_tmp_file_setting
%            -- if present and true, do not set file with
%               extension .tmp_ as temporary file
%
if isempty(obj.f_accessor_)
    return;
end
if nargin < 3
    set_tmp_file_as_tmp = true;
else
    set_tmp_file_as_tmp = ~no_tmp_file_setting;
end
[~,~,fe] = fileparts(filename);
is_tmp = strncmp(fe,'.tmp_',5);
if isstruct(obj.f_accessor_) && isfield(obj.f_accessor_,'memmapfile_struct')
    obj.full_filename = filename;
    obj.f_accessor_ = memmapfile(filename, ...
        'Format', obj.f_accessor_.Format,...
        'Repeat',1,...
        'Writable',obj.f_accessor_.Writable,...
        'Offset',obj.f_accessor_.Offset);

    if set_tmp_file_as_tmp && is_tmp
        obj = obj.set_as_tmp_obj(filename);
    end
else
    error('HORACE:PixelDataFileBacked:runtime_error', ...
        'Invalid internal data for class activation. Class has not been deactivated properly')
end