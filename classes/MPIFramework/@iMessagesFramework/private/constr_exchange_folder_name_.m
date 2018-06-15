function [top_folder,mess_subfolder] = constr_exchange_folder_name_(obj,top_folder)
% extract topmost data folder from the folder, used for filebased messages exchange.
%
%
subfolders_list = {config_store.config_folder_name,obj.exchange_folder_name,obj.job_id};
mess_subfolder = fullfile(subfolders_list{:});
nf = numel(subfolders_list)+1;

[f_b,f_s] = fileparts(top_folder);
for i=1:numel(subfolders_list)
    if strcmpi(f_s,subfolders_list{nf-i})
        top_folder = f_b;
        [f_b,f_s]  = fileparts(top_folder);
    else
        break
    end
end

