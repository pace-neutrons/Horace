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
        function test_extract_job_id_real_header_two_jobs(~)
            clt = ClusterSlurmTester();
            %                                           !<-trim here
            %        1       2            3        4    5       6
            info0 =' 300   debug         bla      abcd  R       10    aa.a..a...a..';            
            info1 =' 300   debug         bla      abcd  R       11    aa.a..a...a..';
            info2 =' 310   debug         bla      abcd  R       1    aa.a..a...a..';            
            clt.squeue_command_output=sprintf('%s\n%s\n',info1,info2);
            
            info0 = split(strtrim(info0));
            prev_info = strjoin(info0(1:5),' ');
            clt = clt.extract_job_id_tester({prev_info});
            
            assertEqual(clt.slurm_job_id,310);
        end
        
        function test_extract_job_id_real_header(~)
            clt = ClusterSlurmTester();
            info =' 300   debug         bla      abcd  R       10    aa.a..a...a..';
            clt.squeue_command_output=sprintf('%s\n',info);
            
            clt = clt.extract_job_id_tester('');
            
            assertEqual(clt.slurm_job_id,300);
        end
        %
        function test_init_parser(~)
            clt = ClusterSlurmTester();
            [uname, pos] = clt.init_parser_tester();
            assertEqual(pos,[5,3]);
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
