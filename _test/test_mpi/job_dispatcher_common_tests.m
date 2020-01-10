classdef job_dispatcher_common_tests< MPI_Test_Common
    % The tests used by any parallel job dispatchers
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
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
            function my_delete(varargin)
                for ii=1:numel(varargin)
                    filename = varargin{ii};
                    if exist(filename,'file')==2
                        delete(filename);
                    end
                end
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
            co = onCleanup(@()(my_delete(files{:})));
            
            jd = JobDispatcher(['test_job_',obj.framework_name,'_fail_restart']);
            
            [outputs,n_failed,~,jd]=jd.start_job('JETester',common_param,36,true,3,true,1);
            
            function is = is_err(x)
                if isa(x,'MException') || isa(x,'ParallelException')
                    is = true;
                elseif iscell(x)
                    is_fail = cellfun(@is_err,x,'UniformOutput',true);
                    is = any(is_fail);
                elseif isstruct(x) && isfield(x,'error') && isa(x.error,'MException')
                    is = true;
                else
                    is = false;
                end
            end
            assertTrue(n_failed>=2);
            assertEqual(numel(outputs),3);
            fin = cellfun(@is_err,outputs);
            assertTrue(sum(fin)>1)
            
            assertEqual(outputs{2}.fail_reason,...
                'Task N2 failed at jobExecutor: JETester. Reason: simulated failure for lab N 2');
            % file may exist or may not -- depending on relation between
            % speed of workers
            
            
            co = onCleanup(@()(my_delete(file3,file3a)));
            common_param.fail_for_labsN  =1:2;
            [outputs,n_failed,~,jd]=jd.restart_job('JETester',common_param,4,true,true,1);
            
            assertTrue(n_failed>=2);
            assertEqual(numel(outputs),3);
            fin = cellfun(@is_err,outputs);
            assertTrue(sum(fin)>1)
            
      
            
            clear co;
            % check long job canceled due to part of the job failed
            [outputs,n_failed,~,jd]=jd.restart_job('JETester',common_param,99,true,true,1);
            
            assertTrue(n_failed>=2);
            assertEqual(numel(outputs),3);
            fin = cellfun(@is_err,outputs);
            assertTrue(sum(fin)>1)
  
            for i=1:33
                fileN = fullfile(obj.working_dir,sprintf('test_JD_%sL3_nf%d.txt',obj.framework_name,i));
                if exist(fileN,'file') == 2
                    delete(fileN);
                else
                    break;
                end
            end
            common_param.fail_for_labsN  =3;
            [outputs,n_failed,~,jd]=jd.restart_job('JETester',common_param,99,true,true,1);
            assertTrue(n_failed>=1);
            assertEqual(numel(outputs),3);
            
            fin = cellfun(@is_err,outputs);
            assertTrue(sum(fin)>1)
            assertEqual(outputs{3}.fail_reason,...
                 'Task N3 failed at jobExecutor: JETester. Reason: simulated failure for lab N 3')
 
            
            for i=1:33
                fileN1 = fullfile(obj.working_dir,sprintf('test_JD_%sL1_nf%d.txt',obj.framework_name,i));
                if exist(fileN1,'file') == 2
                    no_file1 = false;
                    delete(fileN1);
                else
                    no_file1 = true;
                end
                fileN2 = fullfile(obj.working_dir,sprintf('test_JD_%sL2_nf%d.txt',obj.framework_name,i));
                if exist(fileN2,'file') == 2
                    delete(fileN2);
                else
                    if no_file1
                        break;
                    end
                end
            end
            
            
            common_param = rmfield(common_param,'fail_for_labsN');
            files = {file1,file2,file3,file3a};
            co = onCleanup(@()(my_delete(files{:})));
            
            [outputs,n_failed]=jd.restart_job('JETester',common_param,4,true,false,1);
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),3);
            
            assertEqual(outputs{1},'Job 1 generated 1 files');
            assertEqual(outputs{2},'Job 2 generated 1 files');
            assertEqual(outputs{3},'Job 3 generated 2 files');
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            assertTrue(exist(file3a,'file')==2);
            
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
            
            [outputs,n_failed]=jd.start_job('JETester',common_param,30,true,3,false,1);
            
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

