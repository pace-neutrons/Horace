function obj = deactivate_(obj)
% close all open file handles to allow file movements to new
% file/new location.
if isempty(obj.f_accessor_)
    return;
end
if isa(obj.f_accessor_,'memmapfile')
    mmf_struct = struct('memmapfile_struct',true);
    mmf_struct.Filename = obj.f_accessor_.Filename;
    mmf_struct.Format =   obj.f_accessor_.Format;
    mmf_struct.Writable = obj.f_accessor_.Writable;
    mmf_struct.Offset   = obj.f_accessor_.Offset;
    obj.f_accessor_ = mmf_struct;
    if ~isempty(obj.tmp_file_holder_)
        obj.tmp_file_holder_.is_locked = true;
    end
    obj.tmp_file_holder_ = [];
end