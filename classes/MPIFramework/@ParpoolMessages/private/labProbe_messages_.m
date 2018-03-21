function [messages,task_ids] = labProbe_messages_(obj,task_nums,varargin)
% list all messages belonging to the job and retrieve all their names
% for the lobs with id, provided as input.
% if no message is returned for a job, its name cell remains empty.
if ~exist('task_nums','var')
    task_nums = [];
end
% there is bug in Matlab code parser which fails when this is enabled for
% parallel toolbox
% if nargin>2 % tester mode provides non-omp labprobe function
%     if ~isempty(varargin)
%         labProbe = varargin{1};
%     end
% end

if isempty(task_nums)
    task_nums = 1:numlabs;
end
num_tasks = numel(task_nums);
messages  = cell(1,num_tasks );
task_ids   = zeros(1,num_tasks);
num_present = 0;
for i=1:num_tasks
    [isDataAvail,id,tag] = labProbe(task_nums(i));
    if isDataAvail
        messages{i} = MESS_NAMES.mess_name(tag);
        task_ids(i) = id;
        num_present = num_present +1;
    end
end
if num_present == 0
    messages = {};
end

