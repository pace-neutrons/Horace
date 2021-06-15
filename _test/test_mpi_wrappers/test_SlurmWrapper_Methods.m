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
        function extract_job_id_with_trim(~)
            clt = ClusterSlurmTester();
            head = 'JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)';
            info =' 300   debug         bla      abcd  R       10    aa.a..a...a..';
            clt.squeue_command_output=sprintf('%s\n%s\n',head,info);
            
        end
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
            clt.squeue_command_output='10 a b c';
            clt = clt.extract_job_id_tester('');
            assertEqual(clt.slurm_job_id,10);
        end
        
    end
end
