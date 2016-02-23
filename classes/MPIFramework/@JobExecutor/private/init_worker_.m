function [this,argi,mess]=init_worker_(this,job_control_string)
% initiate the worker parameters
%
%
argi = [];
try
    job_control_structe = this.deserialize_par(job_control_string);
catch ME
    mess = ME.message;
    return
end
try
    this.job_ID_           = job_control_structe.job_id;
    this.job_control_pref_ = job_control_structe.file_prefix;
    %
    root_cf = make_config_folder(this.exchange_folder_name);
    job_folder = fullfile(root_cf,this.job_control_pref_);
    if ~exist(job_folder,'dir')
        mess = sprintf('Exchange control folder %s does not exist',job_folder);
        return
    else % HACK! 
        % clear up all messages, which may be initated earlier, if this
        % worker is not be related to them any more!
        if ~strcmp(this.exchange_folder, job_folder)
            this.clear_all_messages();
        end
        this.exchange_folder_ = job_folder;
    end

    
    [ok,mess,message] = this.receive_message('starting');
    if ok
        argi = message.payload;
    else
        return
    end
catch ME
    mess = ME.message;
    return;
end
[~,mess] = this.send_message('started');

