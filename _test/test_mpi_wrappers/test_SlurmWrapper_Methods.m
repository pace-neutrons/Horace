classdef test_SlurmWrapper_Methods < TestCase
    properties
        stored_config ='defaults';
    end

    methods

        function obj = test_SlurmWrapper_Methods(name)
            if ~exist('name', 'var')
                name = 'test_SlurmWrapper_Methods';
            end
            obj = obj@TestCase(name);
        end

        function test_get_state_from_job_control(~)
            states = {'RUNNING', 'RESIZING', 'SUSPENDED','PENDING', 'COMPLETED',...
                'CANCELLED', 'FAILED','TIMEOUT', 'PREEMPTED',...
                'BOOT_FAIL','DEADLINE', 'NODE_FAIL','SomeUnknownState'};
            % running,failed,paused
            reactions = {[true,false,false],[false,false,true],[false,false,true],[false,false,true],...
                [false,false,false],[false,true,false],[false,true,false],...
                [false,true,false],[false,true,false],[false,true,false],...
                [false,true,false],[false,true,false],[false,false,true]};
            messages = {'running','LogMessage','LogMessage','LogMessage','CompletedMessage',...
                'FailedMessage','FailedMessage','FailedMessage','FailedMessage',...
                'FailedMessage','FailedMessage','FailedMessage','LogMessage'};
            react = containers.Map(states,reactions);
            mess_map  = containers.Map(states,messages);

            clt = ClusterSlurmTester();
            for i=1:numel(states)
                state = states{i};
                clt.sacct_command_output = ...
                    sprintf('JobID JobName %s ExitCode',state);
                [running,failed,paused,mess] = clt.get_state_from_job_control_tester();
                reaction = react(state);
                expected_mess = mess_map(state);

                assertEqual(running,reaction(1),...
                    sprintf(' Incorrect running reply for state %s',state));
                assertEqual(failed,reaction(2),...
                    sprintf(' Incorrect failed reply for state %s',state));
                assertEqual(paused,reaction(3),...
                    sprintf(' Incorrect paused reply for state %s',state));
                if ischar(mess)
                    assertEqual(expected_mess,mess,...
                        sprintf(' Incorrect message returned for state %s',state));
                else
                    assertTrue(isa(mess,expected_mess),...
                        sprintf(' Incorrect message returned for state %s',state));
                end
            end
        end

        function test_extract_job_id_real_header_two_jobs(~)
            clt = ClusterSlurmTester();
            % Name of job defaults to undefined here, thus testing to find job called "undefined"
            clt.squeue_command_output=sprintf('%s\n%s\n',...
                                              ' 300   debug_a       bla      abcd  R', ...
                                              ' 310   undefined       bla      abcd  R');
            clt = clt.extract_job_id_tester();

            assertEqual(clt.slurm_job_id,310);
        end

        function test_extract_job_id_real_header(~)
            clt = ClusterSlurmTester();
            % Name of job defaults to undefined here, thus testing to find job called "undefined"
            clt.squeue_command_output=sprintf('%s\n',' 300   undefined         bla      abcd  R ');

            clt = clt.extract_job_id_tester();

            assertEqual(clt.slurm_job_id,300);
        end

        function extract_job_id_from_multistring_log(~)
            % this test requests manual input from user so is not tested
            % automatically
            clt = ClusterSlurmTester();
            % Name of job defaults to undefined here, thus testing to find job called "undefined"
            clt.squeue_command_output = sprintf('%s\n', ...
                        '10 job_a b c', ...
                        '11 undefined f c', ...
                        '12 job_f l k');
            clt = clt.extract_job_id_tester();
            assertEqual(clt.slurm_job_id,11);
        end

        function test_extract_job_id(~)
            clt = ClusterSlurmTester();
            % Name of job defaults to undefined here, thus testing to find job called "undefined"
            clt.squeue_command_output='10 undefined b c 5 6';
            clt = clt.extract_job_id_tester();
            assertEqual(clt.slurm_job_id,10);
        end

        function test_init_parser(~)
            clt = ClusterSlurmTester();
            uname = clt.init_parser_tester();

            [fail,uname_t] = system('whoami');
            assertEqual(fail, 0);
            assertEqual(uname,strtrim(uname_t));
        end

    end
end
