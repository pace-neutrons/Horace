classdef test_parpool_job_dispatcher< test_job_dispatcher
    % Test running using the parpool job dispatcher. 
    %
    % $Revision: 696 $ ($Date: 2018-02-06 13:59:38 +0000 (Tue, 06 Feb 2018) $)
    %
    
    properties
    end
    methods
        %
        function this=test_parpool_job_dispatcher(name)
            if ~exist('name','var')
                name = 'test_parpool_job_dispatcher';
            end
            this = this@test_job_dispatcher(name);
            pc = parallel_config;
            current_pool = pc.parallel_framework;
            try
                pc.parallel_framework = 'parpool';
            catch
                this.skip_tests = true;
            end
            pc.parallel_framework = current_pool;
            this.test_dispatcher = 'parpool';
        end
        %
        function test_job_with_logs_worker(this)
            % overloaded to empty test -- nothing new for this JD
        end
        %
        function test_job_controls_no_running(this)
            % overloaded to empty test -- nothing new for this JD
        end
        %
        function test_split_job_list(this)
            % overloaded to empty test -- nothing new for this JD
        end
        
        
    end
end

