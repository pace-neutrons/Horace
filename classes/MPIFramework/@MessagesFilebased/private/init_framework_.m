function obj = init_framework_(obj,framework_info)
% Internal init_framework method, used to construct functional filebased
% message-exchange framework.
% Input:
%  framework_info -- either:
%             a) string, defining the job name (job_id)
%                 -- or:
%             b) the structure, defined by worker_job_info function:
%                in this case usually defines worker's message exchange
%                framework.
%
if ~exist('framework_info','var')
    error('FILEBASED_MESSAGES:invalid_argument',...
        'inputs for init_framework function is missing')
    
end

if isstruct(framework_info) && isfield(framework_info,'job_id')
    obj.job_id = framework_info.job_id;
    obj.mess_exchange_folder = framework_info.data_path;
    if isfield(framework_info,'labID')
        obj.task_id_ = framework_info.labID;
        obj.numLabs_ = framework_info.numLabs;
    else %
        obj.task_id_ = labindex; % slave node with mpi exchange between nodes. 
        obj.numLabs_ = numlabs;
    end
elseif(is_string(framework_info))
    obj.job_id =[framework_info,'_', char(floor(25*rand(1,10)) + 65)];
    obj.task_id_ = 0;
else
    error('FILEBASED_MESSAGES:invalid_argument',...
        'inputs for init_framework function does not have correct structure')
end
if obj.task_id_ == 0 % Master node
    % create or define the job exchange folder within the configuration folder
    if isempty(obj.mess_exchange_folder)
        [top_folder,exch_subfolder] = obj.build_exchange_folder_name();
        job_folder = make_config_folder(exch_subfolder,top_folder);        
    else
        [folder_root,exch_subfolder] = obj.build_exchange_folder_name(obj.mess_exchange_folder);        
        job_folder = make_config_folder(exch_subfolder,folder_root);                
    end

else % Slave node. Needs correct framework_info for initialization
    [root_cf,exch_subfolder] = obj.build_exchange_folder_name(framework_info.data_path);
    job_folder = fullfile(root_cf,exch_subfolder);
    % despite its name, would not create the folder if it already exist
    job_folder  = make_config_folder(obj.job_id,fileparts(job_folder));
end

obj.mess_exchange_folder = job_folder;

