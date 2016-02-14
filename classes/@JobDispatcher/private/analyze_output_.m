function [is_failed,job,output_exists] = analyze_output_(this,job)
job.is_starting = false;
job.is_running = false;
output_exists = false;
completed_stat_file = this.get_job_stat_file_(job.job_id,this.end_tag_);
[result,is_failed] = analyze_output(completed_stat_file);
if is_failed
    job.failed=true;
else
    job.job_results = result;
end
if ~isempty(result)
    output_exists= true;
end
end



function [result,is_failed] = analyze_output(output_file)
% read file, indicating the job completeon and analyze its contents
% Judge if the file contains any useful information and return this
% information if availible
%
is_failed = false;
f = fopen(output_file);
if f<0
    result = ['Can not open existing result file: ',output_file];
    is_failed = true;
    return
end
    function finalize(fname,fh)
        fclose(fh);
        delete(fname);
    end

clo = onCleanup(@()finalize(output_file,f));
result = [];

% Analyse content
[cont,nsymbols] = fread(f,'uint8');
if nsymbols>=numel('completed')
    status = char(cont(1:numel('completed')));
    if strcmp(status','completed') % no output from the job
        is_failed = false;
        return;
    end
end

if nsymbols>=numel('failed')
    status = char(cont(1:numel('failed')));
    if strcmp(status','failed') % output may indicate the reason for failure
        is_failed = true;
        result = char(cont);
        return;
    end
end
try
    result  = hlp_deserialize(cont);
catch ME
    is_failed = true;
    result = ['failed: Can not convert result from binary format. Reason: ',ME.message];
end
end