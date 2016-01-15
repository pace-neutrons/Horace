function worker(id,is_class,varargin)
% the function used as standard worker to do job in multisessioned matlab.
%
% To work, should be present on a data searh path, availible before Herbert is
% initialized
if isempty(which('herbert_init.m'))
    horace_on();
end

jd = JobDispatcher();
jd = jd.init_job(id);
jd.do_job(is_class,varargin{1});

jd.finish_job();

disp('work completed')


