classdef test_job_dispatcher< TestCase
    %
    % $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
    %
    
    properties
        working_dir
    end
    methods
        %
        function this=test_job_dispatcher(name)
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        function test_jobs_one_worker(this)
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL1_nf2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL1_nf3.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));           
            jobs = cell(3,1);
            for i = 1:numel(jobs)
                jobs{i} = job_param;
            end
            jd = JobDispatcher();
            n_failed=jd.send_jobs(jobs,1,1);
            assertEqual(n_failed,0);
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
        end
        
        function test_jobs_less_workers(this)
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL1_nf2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL2_nf1.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));           
            jobs = cell(3,1);
            for i = 1:numel(jobs)
                jobs{i} = job_param;
            end
            jd = JobDispatcher();
            n_failed=jd.send_jobs(jobs,2,1);
            assertEqual(n_failed,0);
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
        end
        
        % tests themself        
        function test_jobs(this)
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            file1= fullfile(this.working_dir,'test_jobDispatcher1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcher2_nf1.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcher3_nf1.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));           
            jobs = cell(3,1);
            for i = 1:numel(jobs)
                jobs{i} = job_param;
            end
            jd = JobDispatcher();
            n_failed=jd.send_jobs(jobs,3,1);
            assertEqual(n_failed,0);
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
        end
        function test_worker_with_file(this)
            
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            v = hlp_serialize(job_param);
            str_arr =num2str(v);
            str = reshape(str_arr,1,numel(str_arr));
            str  = strrep(str ,' ','x');
            
            jd = JobDispatcher();
            jd = jd.init_job(1);
            fn = jd.starting_job_file_name;
            %
            f = fopen(fn,'wb');
            fwrite(f,str,'char');
            fclose(f);
            
            
            worker('JobDispatcher',1,'-file',fn);

            
            file1= fullfile(this.working_dir,'test_jobDispatcher1_nf1.txt');
            
            assertTrue(exist(file1,'file')==2);
            assertFalse(exist(fn,'file')==2);            
            delete(file1);            
        end
        function test_worker(this)
            
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            v = hlp_serialize(job_param);
            str_arr =num2str(v);
            str = reshape(str_arr,1,numel(str_arr));
            str  = strrep(str ,' ','x');
            
            
            worker('JobDispatcher',1,str);
            worker('JobDispatcher',2,str);
            
            file1= fullfile(this.working_dir,'test_jobDispatcher1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcher2_nf1.txt');
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            delete(file1);
            delete(file2);            
            
        end
        
        
        function test_do_job(this)
            %
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            v = hlp_serialize(job_param);
            str_repr =num2str(v);
            str_repr = reshape(str_repr,1,numel(str_repr));
            str_repr  = strrep(str_repr,' ','x');
            
            
            jd = JobDispatcher();
            jd.do_job(str_repr);
            assertTrue(exist(fullfile(this.working_dir,'test_jobDispatcher0_nf1.txt'),'file')==2);
            delete(fullfile(this.working_dir,'test_jobDispatcher0_nf1.txt'));
        end
        
        
    end
end

