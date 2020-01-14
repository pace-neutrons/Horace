function   obj = generate_log_(obj,log_message)
% Display JobDispatcher log message
%
count = obj.display_results_count_;
if verLessThan('matlab','9.1')
    CR = sprintf('\n');
else
    CR = newline; %sprintf('\n');
end
if count > 0
    log = CR;
else
    log = '';
end

if exist('log_message','var')
    obj.display_results_count_ = 0;
    n_symbols = numel(log_message);
    if n_symbols <=obj.LOG_MESSAGE_LENGHT
        format = ['**** %-',num2str(obj.LOG_MESSAGE_LENGHT),'s ****',CR];
        log =[log,sprintf(format,log_message)];
    else
        log =[log,sprintf('**** %s\n',log_message)];
    end
else % report internal state of the JobDispatcher
    
    if obj.status_changed
        info = gen_job_info(obj);
        log = [log,info,CR];
        %obj.status_changed_ = false;
        count = -1;
    else
        if count < obj.LOG_MESSAGE_WRAP_LENGTH
            log = '.';
        else
            count = -1;
            info = gen_job_info(obj);
            log = [CR,info,CR];
        end
    end
    count = count+1;
    obj.display_results_count_ = count;
end
obj.log_value_ = log;

function info=gen_job_info(obj)
% return the string, containing information about the task state
% given
stateMess = obj.status;
if isempty(stateMess)
    info = sprintf('***Job : %s : state: unknown |',obj.job_id);
    return;
end
name = stateMess.mess_name;
if strcmpi(name,'log')
    name = 'running';
end
info = sprintf('***Job : %s : state: %8s |',obj.job_id,name);
if isa(stateMess,'LogMessage')
    if stateMess.time_per_step == 0
        info = [info, sprintf('Step#%.2f/%d, Estimated time left:  Unknown | ',...
            stateMess.step,stateMess.n_steps),stateMess.add_info];
    else
        time_left = (stateMess.n_steps-stateMess.step)*stateMess.time_per_step/60;
        info = [info, sprintf('Step#%.2f/%d, Estimated time left: %4.2f(min)| ',...
            stateMess.step,stateMess.n_steps,time_left),stateMess.add_info];
    end
elseif stateMess.tag == MESS_NAMES.mess_id('failed')
    err = stateMess.payload;
    if isnumeric(err)
        info = [info,num2str(err)];
        %     elseif isa(err,'MExeption') || isa(err,'ParallelException')
        %         for i=1:numel(err.stack)
        %             info = [info,err.stack{i}];
        %         end
    end
end
