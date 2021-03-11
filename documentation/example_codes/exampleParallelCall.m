jd = JobDispatcher('JobName');              % Create job dispatcher

[outputs, ...                               % Cell array of results from each worker
 n_failed,...                               % Count of failed workers
 task_ids,...                               % IDs of each worker (message folder?)
 jd       ...                               % Object returns itself when done
 ] = jd.start_job('ExampleJobExecutor', ... % Name of class to run
                  [1,2], ...                % Data passed to all classes via common_data
                  10, ...                   % Number of "iterations" as int or cellarr of
                  ...                       % structures of data to pass to each worker
                  true, ...                 % Return outputs from workers
                  4);                       % Number of workers

disp(outputs);
disp(n_failed);
disp(task_ids);
disp(jd);
jd = JobDispatcher('RunWithInt');              % Create job dispatcher

% Run with int loop count
[outputs, n_failed, task_ids, jd] = jd.start_job('ExampleRealJobExecutor', [1,2], 10, true, 4);

disp(outputs);
disp(n_failed);
disp(task_ids);
disp(jd);
jd = JobDispatcher('RunWithCellStruct');              % Create job dispatcher

% Run with struct to split
data = {struct('a',1), struct('a',2), struct('a',3), struct('a',4)};
[outputs, n_failed, task_ids, jd] = jd.start_job('ExampleRealJobExecutor', [1,2], data, true, 4);

disp(outputs);
disp(n_failed);
disp(task_ids);
disp(jd);
jd = JobDispatcher('RunWithStruct');              % Create job dispatcher

% Run with struct whose first field denotes job count(?)
data = struct('nJobs',10);
[outputs, n_failed, task_ids, jd] = jd.start_job('ExampleRealJobExecutor', [1,2], data, true, 4);

disp(outputs);
disp(n_failed);
disp(task_ids);
disp(jd);
