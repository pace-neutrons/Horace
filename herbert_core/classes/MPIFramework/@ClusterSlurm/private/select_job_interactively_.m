function job_id_str=select_job_interactively_(new_job_info)
% function to select proper slurm job interactively
% 
% This should never happen
fprintf(2,'*** WARNING: more then one new job have found in the slurm queue\n')
fprintf(2,'*** The jobs are:\n')
fprintf(2,'*** |------------|-------------------\n')
fprintf(2,'*** | Job number |  Job info\n')
fprintf(2,'*** |------------|-------------------\n')
for i=1:numel(new_job_info)
    fprintf(2,'*** | %10i |  %s\n',i,new_job_info{i})
end
fprintf(2,'*** |------------|-------------------\n')

job_id_num = 0;
while job_id_num<1 || job_id_num>numel(new_job_info)
    fprintf(2,'*** select job information number in the range: [1,%d]\n',...
        numel(new_job_info))
    fprintf(2,'*** ?')
    stri = input('','s');
    job_id_num = str2double(stri);
end
fprintf(2,'*** Job N %d with info: ''%s'' selected\n',...
    job_id_num,new_job_info{job_id_num})
job_id_str = new_job_info(job_id_num);
