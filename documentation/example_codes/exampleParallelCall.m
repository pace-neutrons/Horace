% Runnable Example Code
%{
jd = JobDispatcher('JobName');              % Create job dispatcher

[outputs, ...                               % Cell array of results from each worker
 n_failed,...                               % Count of failed workers
 task_ids,...                               % IDs of each worker (message folder?)
 jd       ...                               % Object returns itself when done
 ...
 ] = jd.start_job('ExampleJobExecutor', ... % Name of class to run
                  [1,2], ...                % Data passed to all classes via common_data
                  10, ...                   % Number of "iterations" as int, or
                  ...                       %      cellarr of structures of data to pass to each worker
                  ...
                  true, ...                 % Return outputs from workers
                  4);                       % Number of workers

%}

%%------------------------------------------------------------------

% Run with int loop count
jd = JobDispatcher('RunWithInt');
[outputs, n_failed, task_ids, jd] = jd.start_job('ExampleRealJobExecutor', [1,2], 10, true, 4);

celldisp(outputs);
disp(n_failed);
disp(task_ids);
disp(jd);

%%------------------------------------------------------------------

% Run with cell array of data
jd = JobDispatcher('RunWithCellStruct');
data = {struct('a',1), struct('a',2), struct('a',3), struct('a',4)};
[outputs, n_failed, task_ids, jd] = jd.start_job('ExampleRealJobExecutor', [1,2], data, true, 4);

celldisp(outputs);
disp(n_failed);
disp(task_ids);
disp(jd);

%%------------------------------------------------------------------

% Run with struct whose first field denotes job count(?)
jd = JobDispatcher('RunWithStruct');
data = struct('a',{{1,2,3,4}},'b',{{2,2,3,4}}); % Cell arrs must be same size
[outputs, n_failed, task_ids, jd] = jd.start_job('ExampleRealJobExecutor', [1,2], data, true, 4);

celldisp(outputs);
disp(n_failed);
disp(task_ids);
disp(jd);
