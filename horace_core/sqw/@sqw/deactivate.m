function obj = deactivate(obj)
% Close all open handles of the class keeping information about
% file in memory and allowing external operations with backing files
% It also may be used to transfer opened files to parallel
% workers.
%
% Clears tmp obj status, if it was present
obj.pix = obj.pix.deactivate();
if ~isempty(obj.tmp_file_holder_)
    obj.tmp_file_holder_.lock();
end
obj.tmp_file_holder_ = [];
