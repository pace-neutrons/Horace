classdef test_job_dispatcher_parpool< job_dispatcher_common_tests
    % Test running using the parpool job dispatcher.

    properties
    end
    methods
        %
        function this=test_job_dispatcher_parpool(name)
            if ~exist('name', 'var')
                name = 'test_job_dispatcher_parpool';
            end
            this = this@job_dispatcher_common_tests(name,'parpool');
            this.print_running_tests = true;
        end
        function delete(~)
            pl = gcp('nocreate'); % Get the current parallel pool
            delete(pl);
        end
        %

        function xest_job_submittion(obj)
            % test to debug job submission on cluster. It's not usually run
            % as all logic is tested elsewhere but kept to help identifying
            % the issues with job submission on a cluster.
            if obj.ignore_test
                skipTest(obj.ignore_cause);
            end
            % delete interactive parallel cluster if any exist
            cl = gcp('nocreate');
            if ~isempty(cl)
                delete(cl);
            end

            cl  = parcluster();
            cjob = createCommunicatingJob(cl,'Type','SPMD');
            cjob.NumWorkersRange = 3;
            cjob.AutoAttachFiles = false;
            file1= 'test_file_Process1.txt';
            file2= 'test_file_Process2.txt';
            file3= 'test_file_Process3.txt';
            clob1 = onCleanup(@()delete(file1,file2,file3));

            function create_test_file(name)
                ind = labindex();
                fName = sprintf('test_file_Process%d.txt',ind);
                fh = fopen(fName,'w');
                clob = onCleanup(@()fclose(fh));
                fprintf(fh,'file created from process %d, Input: %s',ind,name);
            end
            task = createTask(cjob,@create_test_file,0,{'bla_bla'});
            submit(cjob);


            wait(cjob)
            assertTrue(is_file(file1));
            assertTrue(is_file(file2));
            assertTrue(is_file(file3));
            delete(cjob)
        end
        %
        function test_job_fail_restart(obj, varargin)
            test_job_fail_restart@job_dispatcher_common_tests(obj, varargin{:})
        end
        %
        function test_job_with_logs_3workers(obj, varargin)

            test_job_with_logs_3workers@job_dispatcher_common_tests(obj, varargin{:})
        end
        %
        function test_job_with_logs_2workers(obj,varargin)
            test_job_with_logs_2workers@job_dispatcher_common_tests(obj, varargin{:})
        end
        %
        function test_job_with_logs_worker(obj, varargin)
            test_job_with_logs_worker@job_dispatcher_common_tests(obj, varargin{:})
        end

    end

end
