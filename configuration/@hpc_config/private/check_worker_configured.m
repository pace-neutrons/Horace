function [ok,mess] = check_worker_configured(obj)
% Check if worker configured properly to allow it Horace multisession
% processing
%

wrker_path = fileparts(which(obj.current_worker_to_use_));
if isempty(wrker_path)
    ok=false;
    mess=['Can not find worker on a data search path;\n',...
        'See: http://horace.isis.rl.ac.uk/Download_and_setup#Enabling_multi-sessions_processing\n',...
        'for the details on how to set it up'];
else
    ok=true;
    mess = '';
end

