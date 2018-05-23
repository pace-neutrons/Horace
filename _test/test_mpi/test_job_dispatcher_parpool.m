classdef test_job_dispatcher_parpool< MPI_Test_Common
    % Test running using the parpool job dispatcher. 
    %
    % $Revision: 696 $ ($Date: 2018-02-06 13:59:38 +0000 (Tue, 06 Feb 2018) $)
    %
    
    properties
        skip_tests  = false;
    end
    methods
        %
        function this=test_job_dispatcher_parpool(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_parpool';
            end
            this = this@MPI_Test_Common(name);
        end
        %
        function test_job_with_logs_worker(this,varargin)
            if this.skip_tests
                return;
            end
            if nargin>1
                this.setUp();
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
            
            jd = JobDispatcher('test_parpool_1worker');
            
            [outputs,n_failed]=jd.start_tasks('JETester',common_param,3,true,1,false,1);
            
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),1);
            assertEqual(outputs{1},'Job 1 generated 3 files');            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        %
        function test_job_with_logs_2workers(this,varargin)
            if this.skip_tests
                return;
            end
            if nargin>1
                this.setUp();
                clob0 = onCleanup(@()tearDown(this));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');                        
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL2_nf1.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL2_nf2.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher('test_parpool_2workers');
            
            [outputs,n_failed]=jd.start_tasks('JETester',common_param,3,true,2,false,1);
            
            assertEqual(n_failed,0);
            assertTrue(isempty(outputs{1}));
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        %
        
        
    end
end

