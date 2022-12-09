function obj = fclose_(obj)
% Close existing file header if it has been opened
fn = fopen(obj.file_id_);
if ~isempty(fn)
    fclose(obj.file_id_);
end
obj.file_id_ = -1;
