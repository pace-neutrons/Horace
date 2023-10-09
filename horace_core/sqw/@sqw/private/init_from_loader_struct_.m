function obj = init_from_loader_struct_(obj, data_struct)
% initialize object contents using structure, obtained from
% file loader
%
obj.main_header = data_struct.main_header;
if isfield(data_struct,'header') % support for old data
    obj.experiment_info = data_struct.header;
else
    obj.experiment_info = data_struct.experiment_info;
end
% keep only experiments, which contribute into pixels. Old file format may
% contain experiments, which do not contribute to pixels.
if ~isempty(data_struct.pix) && data_struct.pix.old_file_format && ...
        ~isempty(data_struct.pix.unique_run_id)
    obj.experiment_info = data_struct.experiment_info.get_subobj(data_struct.pix.unique_run_id);
    % old file format is irrelevant now, as all data are in memory
    data_struct.pix.old_file_format = false;
end

obj.detpar = data_struct.detpar;
obj.data = data_struct.data;
obj.pix = data_struct.pix;
