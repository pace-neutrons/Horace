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
        % tests themself
        function test_jobs(this)
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d.txt');
            
            file1= fullfile(this.working_dir,'test_jobDispatcher1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcher2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcher3.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));           
            jobs = cell(3,1);
            for i = 1:numel(jobs)
                jobs{i} = job_param;
            end
            jd = JobDispatcher();
            jd.send_jobs(jobs);
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
        end
        function test_worker(this)
            
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d.txt');
            v = hlp_serialize(job_param);
            str_arr =num2str(v);
            str = reshape(str_arr,1,numel(str_arr));
            str  = strrep(str ,' ','x');
            
            
            worker(1,false,str);
            worker(2,false,str);
            
            file1= fullfile(this.working_dir,'test_jobDispatcher1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcher2.txt');
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            delete(file1);
            delete(file2);            
            
        end
        
        function test_do_job(this)
            %
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d.txt');
            v = hlp_serialize(job_param );
            str_repr =num2str(v);
            str_repr = reshape(str_repr,1,numel(str_repr));
            str_repr  = strrep(str_repr,' ','x');
            
            
            jd = JobDispatcher();
            jd.do_job(false,str_repr);
            assertTrue(exist(fullfile(this.working_dir,'test_jobDispatcher0.txt'),'file')==2);
            delete(fullfile(this.working_dir,'test_jobDispatcher0.txt'));
        end
        
        
    end
end

