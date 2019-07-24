function [top_folder,mess_subfolder] = constr_exchange_folder_name_(obj,top_folder)
% extract topmost data folder from the folder, used for filebased messages exchange.
%
%
cfn = config_store.instance().config_folder_name;
subfolders_list={obj.exchange_folder_name,obj.job_id};

f_s = regexp(top_folder,filesep,'split');
if isempty(f_s{1});  f_s{1} = filesep;
end
coinside = ismember(f_s,cfn);
if any(coinside)
    cind = find(coinside,1)-1;
    top_folder = fullfile(f_s{1:cind});
end
top_folder = fullfile(top_folder,cfn);
mess_subfolder = fullfile(subfolders_list{:});