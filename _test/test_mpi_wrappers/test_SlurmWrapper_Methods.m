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
            info0 =' 300   debug         bla      abcd  R ';
            info1 =' 300   debug         bla      abcd  R ';
            info2 =' 310   debug         bla      abcd  R';
            clt.squeue_command_output=sprintf('%s\n%s\n',info1,info2);
            
            clt = clt.extract_job_id_tester({info0});
            
            assertEqual(clt.slurm_job_id,310);
        end
        
        function test_extract_job_id_real_header(~)
            clt = ClusterSlurmTester();
            info =' 300   debug         bla      abcd  R ';
            clt.squeue_command_output=sprintf('%s\n',info);
            
            clt = clt.extract_job_id_tester('');
            
            assertEqual(clt.slurm_job_id,300);
        end
        %
        function test_init_parser(~)
            clt = ClusterSlurmTester();
            uname = clt.init_parser_tester();
            
            [fail,uname_t] = system('whoami');
            assertEqual(fail,0);
            assertEqual(uname,strtrim(uname_t));
        end
        %
        function extract_job_id_from_multistring_log_manually(~)
            % this test requests manual input from user so is not tested
            % automatically
            clt = ClusterSlurmTester();
            clt.squeue_command_output=...
                sprintf('10 a b c\n11 d f c\n12   d l k');
            clt = clt.extract_job_id_tester('10 a b c');
            assertEqual(clt.slurm_job_id,11);
        end
        
        function test_extract_job_id_from_multistring_log(~)
            clt = ClusterSlurmTester();
            clt.squeue_command_output=...
                sprintf('10 a b c\n 11 d f c');
            clt = clt.extract_job_id_tester('10 a b c');
            assertEqual(clt.slurm_job_id,11);
        end
        
        function test_extract_job_id(~)
            clt = ClusterSlurmTester();
            clt.squeue_command_output='10 a b c 5 6';
            clt = clt.extract_job_id_tester('');
            assertEqual(clt.slurm_job_id,10);
        end
        
    end
end
