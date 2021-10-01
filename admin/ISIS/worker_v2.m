function [ok,err_mess,je]=worker_v2(worker_controls_string)
% function used as standard worker to do a job in a separate Matlab
% session.
%
% To work, should be present on a data search path, before Herbert is
% initialized as may need to initialize Herbert and Horace itself
%
%Inputs:
% worker_controls_string - the structure, containing information, necessary to
%              initiate the job.
%              Due to the fact this string is transferred
%              through pipes its size is system dependent and limited, so
%              contains only minimal initialization information, namely the
%              folder name where the job initialization data are located on
%              a remote system.
if nargin<1 || isempty(worker_controls_string)    
    worker_controls_string = getenv('WORKER_CONTROL_STRING'); 
end

je = [];
ok = false;
if isempty(which('herbert_init.m'))
    try
        horace_on();
    catch ME
        err_mess = ME;
        write_fail_log(ME)
        return;
    end
end

DO_LOGGING = getenv('DO_PARALLEL_MATLAB_LOGGING');
if isempty(DO_LOGGING)
    DO_LOGGING = false;
else
    DO_LOGGING = feval(DO_LOGGING);
end
DO_DEBUGGING = false;
try
    [ok, err_mess,je] = parallel_worker(worker_controls_string,DO_LOGGING,DO_DEBUGGING);
catch ME1 % intercepted exception in processing failure or some odd bug indeed
    write_fail_log(ME1);
    err_mess = ME1;
end
if ~ok 
    write_fail_log(err_mess);
end

function write_fail_log(ERROR)
%
pid = int64(feature('getpid'));
log_file_name  = sprintf('WORKER_V2_Process_%d_failure.log',pid);
log_file = fullfile(getuserdir,log_file_name );

if isa(ERROR,'MException')
    error_contents = ERROR.getReport();
else
    error_contents = fevalc('disp(ERROR)');
end

fh = fopen(log_file,'w');
if fh<1
    warning('Can not open log file %s for writing',log_file);
    return; % well, can not write log file, sorry but logs can be available trough Matlab logs.
end
try
    fprintf(fh,'******* Unhandled exception:\n');
    fprintf(fh,'******** ERROR: \n');
    fprintf(fh,'%s',error_contents );
    stat = fclose(fh);    
catch ERR % again, may be log will clarify the situation
    warning('Can not write log file %s; Reason %s',log_file,getReport(ERR));
end


