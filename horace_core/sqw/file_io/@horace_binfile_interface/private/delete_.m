function obj = delete_(obj)
% Destructor.
% close all associated files and nullify all information about internal
% structure of the file from memory.

if ~isempty(obj.file_closer_)
    obj.file_closer_.delete();
end
obj.sqw_holder_ = [];
obj.file_id_ = -1;
obj.num_dim_ = 'undefined';
