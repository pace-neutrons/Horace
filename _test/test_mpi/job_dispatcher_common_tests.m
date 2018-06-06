classdef job_dispatcher_common_tests< MPI_Test_Common
    % The tests used by any parrallel job dispatchers
    %
    % $Revision: 696 $ ($Date: 2018-02-06 13:59:38 +0000 (Tue, 06 Feb 2018) $)
    %
    
    properties
    end
    methods
        %
        function this=job_dispatcher_common_tests(test_name,framework_name)
            this = this@MPI_Test_Common(test_name,framework_name);
        end
        function test_job_fail_restart(obj,varargin)
            if obj.ignore_test
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',obj.working_dir,...
                'filename_template',['test_JD_',obj.framework_name,'L%d_nf%d.txt'],...
                'fail_for_labsN',2);
            
            file1= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L1_nf1.txt']);
            file2= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L2_nf1.txt']);
            file3= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L3_nf1.txt']);
            file3a= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L3_nf2.txt']);
            
            files = {file1,file3,file3a};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher(['test_job',obj.framework_name,'_fail_restart']);
            
            [outputs,n_failed,~,jd]=jd.start_job('JETester',common_param,4,true,3,true,1);
            
            assertEqual(n_failed,1);
            assertEqual(numel(outputs),3);
            assertTrue(isa(outputs{2},'MException'));
            %assertEqual(outputs{1},'Job 1 generated 1 files');
            %assertEqual(outputs{2},'Job 2 generated 1 files'); % this one
            %fails
            %assertEqual(outputs{3},'Job 3 generated 1 files');
            assertTrue(exist(file1,'file')==2);
            assertFalse(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            assertTrue(exist(file3a,'file')==2);
            co = onCleanup(@()(delete(file3,file3a)));
            
            common_param.fail_for_labsN  =1:2;
            [outputs,n_failed,~,jd]=jd.restart_job('JETester',common_param,4,true,true,1);
            
            assertEqual(n_failed,2);
            assertEqual(numel(outputs),3);
            assertTrue(isa(outputs{1},'MException'));
            assertTrue(isa(outputs{2},'MException'));
            assertFalse(exist(file1,'file')==2);
            assertFalse(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            assertTrue(exist(file3a,'file')==2);
            
            common_param = rmfield(common_param,'fail_for_labsN');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            [outputs,n_failed]=jd.restart_job('JETester',common_param,3,true,false,1);
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),3);
            
            assertEqual(outputs{1},'Job 1 generated 1 files');
            assertEqual(outputs{2},'Job 2 generated 1 files');
            assertEqual(outputs{3},'Job 3 generated 1 files');
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        
        %
        %
        function test_job_with_logs_2workers(obj,varargin)
            if obj.ignore_test
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',obj.working_dir,...
                'filename_template',['test_JD_',obj.framework_name,'L%d_nf%d.txt']);
            
            file1= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L1_nf1.txt']);
            file2= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L2_nf1.txt']);
            file3= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L2_nf2.txt']);
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher(['test_',obj.framework_name,'_2workers']);
            
            [outputs,n_failed]=jd.start_job('JETester',common_param,3,true,2,false,1);
            
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),2);
            assertEqual(outputs{1},'Job 1 generated 1 files');
            assertEqual(outputs{2},'Job 2 generated 2 files');
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        %
        function test_job_with_logs_3workers(obj,varargin)
            if obj.ignore_test
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',obj.working_dir,...
                'filename_template',['test_JD_',obj.framework_name,'L%d_nf%d.txt']);
            
            file1= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L1_nf1.txt']);
            file2= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L2_nf1.txt']);
            file3= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L3_nf1.txt']);
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher(['test_',obj.framework_name,'_3workers']);
            
            [outputs,n_failed]=jd.start_job('JETester',common_param,3,true,3,false,1);
            
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),3);
            assertEqual(outputs{1},'Job 1 generated 1 files');
            assertEqual(outputs{2},'Job 2 generated 1 files');
            assertEqual(outputs{3},'Job 3 generated 1 files');
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        function test_job_with_logs_worker(obj,varargin)
            if obj.ignore_test
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',obj.working_dir,...
                'filename_template',['test_JD_',obj.framework_name,'L%d_nf%d.txt']);
            
            file1= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L1_nf1.txt']);
            file2= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L1_nf2.txt']);
            file3= fullfile(obj.working_dir,['test_JD_',obj.framework_name,'L1_nf3.txt']);
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher(['test_',obj.framework_name,'_1worker']);
            
            [outputs,n_failed]=jd.start_job('JETester',common_param,3,true,1,false,1);
            
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),1);
            assertEqual(outputs{1},'Job 1 generated 3 files');
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        
        
    end
end

