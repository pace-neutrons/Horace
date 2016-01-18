function worker(class_name,id,is_class,varargin)
% function used as standard worker to do a job in different matlab
% session
%
% To work, should be present on a data searh path, availible before Herbert is
% initialized
%
%Inputs:
% class_name -- the name of the class, which do job distribution. The class
%               should inherit from JobDispatcher and overload at least
%               do_job method
%
% id         -- unique number which distinguish this job from any other
%               running job, and used by JobDispatcher to identify jobs.
%
% is_class   -- boolean which indicate if job parameters are defined by a
%               class, which has conversion from string method, or a
%               structure.
%               Only rundata class is currently accepted
%
% varargin   -- sellarray of strings, to deserialize into input
%               parameters for the jobs
%
%
    function del_quet(fname)
        if exist(fname,'file') == 2
            delete(fname)
        end
    end

if isempty(which('herbert_init.m'))
    horace_on();
end

jd = feval(class_name);
%
jd = jd.init_job(id);
% make sure that run id is deleted if this job have failed
run_fname = jd.running_job_file_name;
clo = onCleanup(@()del_quet(run_fname));
%
jd.do_job(is_class,varargin{:});
%
jd.finish_job();

end