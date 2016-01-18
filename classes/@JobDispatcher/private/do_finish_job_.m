function this=do_finish_job_(this)
% set up tag, indicateing that the job have finished
%
running_stat_file  = this.get_job_stat_file_(this.job_id,this.run_tag_);
if exist(running_stat_file ,'file')==2
    delete(running_stat_file )
end
starting_stat_file  = this.get_job_stat_file_(this.job_id,this.start_tag_);
if exist(starting_stat_file ,'file')==2
    delete(running_stat_file );
end
%
finish_stat_file  = this.get_job_stat_file_(this.job_id,this.end_tag_);
f = fopen(finish_stat_file  ,'w');
fwrite(f,'completed','char');
fclose(f);

this.job_ID_=0;


