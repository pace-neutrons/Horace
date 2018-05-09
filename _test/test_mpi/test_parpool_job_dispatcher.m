classdef test_parpool_job_dispatcher< MPI_Test_Common
    % Test running using the parpool job dispatcher. 
    %
    % $Revision: 696 $ ($Date: 2018-02-06 13:59:38 +0000 (Tue, 06 Feb 2018) $)
    %
    
    properties
        skip_tests  = false;
    end
    methods
        %
        function this=test_parpool_job_dispatcher(name)
            if ~exist('name','var')
                name = 'test_parpool_job_dispatcher';
            end
            this = this@MPI_Test_Common(name);
        end
        %
        function test_job_with_logs_worker(this,varargin)
            if this.skip_tests
                return;
            end
            if nargin>1
                clob0 = onCleanup(@()tearDown(this));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');                        
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL1_nf2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL1_nf3.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher();
            
            [n_failed,outputs]=jd.start_tasks('JETester',common_param,3,1,1);
            
            assertEqual(n_failed,0);
            assertTrue(isempty(outputs{1}));
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
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

