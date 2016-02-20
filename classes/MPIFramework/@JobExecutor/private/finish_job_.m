function [ok,err_mess]=finish_job_(this)
% set up tag, indicating that the job have finished and store output job
% results in the output file, if the job produces outputs.
%
mess = aMessage('completed');
mess.payload = this.job_outputs;
[ok,err_mess] = this.send_message(mess);

%Cannibalize "started" and "running" messages if such have not
%yet been picked up by a job dispatcher
this.receive_message('started');
this.receive_message('running');



