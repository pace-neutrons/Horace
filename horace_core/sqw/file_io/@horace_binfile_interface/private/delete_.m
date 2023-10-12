function obj = delete_(obj)
% Destructor.
% close all associated files and nullify all information about internal
% structure of the file from memory.

if ~isempty(obj.file_closer_)
% Re #1322 refactoring is due
    obj.file_closer_.delete();
    obj.file_closer_ = [];
end
obj = obj.fclose();
obj.sqw_holder_ = [];
obj.num_dim_ = 'undefined';
