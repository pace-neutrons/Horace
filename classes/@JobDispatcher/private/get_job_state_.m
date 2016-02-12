function  ok = get_job_state_(this,job,state)
% check if job status corresponds to the requested

   if strcmpi(state,this.start_tag_)
      stat_file = get_job_stat_file_(this,job.job_id,this.start_tag_);       
   elseif strcmpi(state,this.run_tag_)
      stat_file = get_job_stat_file_(this,job.job_id,this.run_tag_);              
   elseif strcmpi(state,this.end_tag_)
      stat_file = get_job_stat_file_(this,job.job_id,this.end_tag_);                     
   else
       error('JOBDISPATCHER:get_job_state','unsupported job state %s',state)
   end
   if exist(stat_file,'file') == 2
       ok = true;
   else
       ok = false;       
   end

end