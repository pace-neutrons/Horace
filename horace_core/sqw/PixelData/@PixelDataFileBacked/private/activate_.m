function obj = activate_(obj,filename)
% open file access for file, previously closed by deactivate
% operation, possibly using new file name
if isempty(obj.f_accessor_)
    return;
end

if isstruct(obj.f_accessor_) && isfield(obj.f_accessor_,'memmapfile_struct')
    obj.full_filename = filename;
    obj.f_accessor_ = memmapfile(filename, ...
        'Format', obj.f_accessor_.Format,...
        'Repeat',1,...
        'Writable',obj.f_accessor_.Writable,...
        'Offset',obj.f_accessor_.Offset);
    [~,~,fe] = fileparts(filename);
    if strncmp(fe,'.tmp_',5)
        obj = obj.set_as_tmp_obj(filename);
    end
else
    error('HORACE:PixelDataFileBacked:runtime_error', ...
        'Invalid internal data for class activation. Class has not been deactivated properly')
end