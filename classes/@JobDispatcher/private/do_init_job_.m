function [this,argi]=do_init_job_(this,id,varargin)
% set up tag, indicating that the job have started

this.job_ID_ = id;
read_inputs_from_file=false;
argi = {};
if nargin>2
    read_inputs_from_file = true;
end

starting_stat_file = this.get_job_stat_file_(id,this.start_tag_);
if exist(starting_stat_file,'file')==2
    if read_inputs_from_file 
        f = fopen(starting_stat_file,'rb');
        if f<0
            error('JOB_DISPATCHER:init_job',' Can not open input parameters file %s',...            
            starting_stat_file);                
        end
        char_arg = char(fread(f,'char')');
        fclose(f);
        argi = regexp(char_arg,',','split');
    end
    delete(starting_stat_file)
else
    if read_inputs_from_file 
        error('JOB_DISPATCHER:init_job',' Requested to read job parameters from file %s but the file does not exist',...
            starting_stat_file);
    end
end

running_stat_file  = this.get_job_stat_file_(id,this.run_tag_);
f = fopen(running_stat_file  ,'w');
fwrite(f,'running','char');
fclose(f);

