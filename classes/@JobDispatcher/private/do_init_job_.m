function this=do_init_job_(this,id)
% set up tag, indicating that the job have started

this.job_ID_ = id;
running_stat_file  = this.get_job_stat_file_(id,this.run_tag_);
starting_stat_file = this.get_job_stat_file_(id,this.start_tag_);
if exist(starting_stat_file,'file')==2
    delete(starting_stat_file)
end
f = fopen(running_stat_file  ,'w');
fwrite(f,'running','char');
fclose(f);

