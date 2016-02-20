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

