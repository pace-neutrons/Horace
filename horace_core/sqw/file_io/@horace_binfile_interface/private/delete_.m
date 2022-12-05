function obj = delete_(obj)
% Destructor.
% close all associated files and nullify all information about internal 
% structure of the file from memory.

if ~isempty(obj.file_closer_)
    clOb = obj.file_closer_;
    obj.file_closer_ = [];
end
obj = obj.fclose();
obj.sqw_holder_ = [];
