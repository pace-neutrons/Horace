classdef test_symm_equivalent_zones< TestCase
    %
    % Validate the dnd symmetrisation, combination and rebin routines
    
    
    % Copied from template in test_multifit_horace_1
    properties
        testdir;
    end
    
    
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_symm_equivalent_zones(name)
            
            this=this@TestCase(name);
            this.testdir = fileparts(mfilename('fullpath'));
            
            %w3d_d3d=read_dnd(fullfile(testdir,'w3d_d3d.sqw'));
            
            
            
        end
        function test_worker(this)
            mis = MPI_State.instance();
            mis.is_tested = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            
            
            proj = projection([1,1,0],[1,-1,0]);
            pos = [1,1,0];
            zone1=[1,-1,0];
            data_source = fullfile(this.testdir,'w3d_sqw.sqw');
            outdir  = tempdir;
            outfiles = {fullfile(outdir ,'HoracePartialZoneN1_file_partN0.tmp'),...
                fullfile(outdir ,'HoracePartialZoneN2_file_partN0.tmp')}  ;
            cob = onCleanup(@()delete(outfiles{:}));
            range1 = qe_range(-0.1,0.025,0.1);
            ranges = cell(2,1);
            ranges{1} = [range1,range1,qe_range(-Inf,Inf),qe_range(0,1.5,100)];
            ranges{2} = ranges{1};
            ranges{1}(1).center = zone1(1);
            ranges{1}(2).center = zone1(2);
            ranges{1}(3).center = zone1(3);
            ranges{2}(1).center = pos(1);
            ranges{2}(2).center = pos(2);
            ranges{2}(3).center = pos(3);
            zones = {zone1;pos};
            zoneid=cell(2,1);
            zoneid{1}= 1;
            zoneid{2}= 2;
            
            job_par_fun = @(id,x,y)(combine_equivalent_zones_job.param_f(...
                id,x,y(1),y(2),y(3),y(4),proj,pos,data_source,outdir));
            
            % the job parameter lost to process two zones
            job_param_list  = cellfun(job_par_fun,zoneid,zones,ranges);
            
            
            
            jd = JobDispatcher('test_sym_equiv_zones_worker');
            % split jobs on single worker
            [~,~,wc]=jd.split_and_register_jobs(job_param_list,1);
            
            worker('combine_equivalent_zones_job',wc{1});
            %--------------------------
            % receive results of the work
            [ok,err,mes] = jd.receive_message(1,'completed');
            assertTrue(ok);
            assertTrue(isempty(err));
            res = mes.payload;
            %out = struct('zone_id',zone_id,'zone_files',[]);
            %
            jd.clear_all_messages();
            %
            assertEqual(numel(res.zone_id),2);
            assertEqual(res.zone_id(1),1);
            assertEqual(res.zone_id(2),2);
            
            assertTrue(exist(fullfile(outdir,res.zone_files{1}),'file')==2)
            assertTrue(exist(fullfile(outdir,res.zone_files{2}),'file')==2)
        end
        
        function test_do_job(this)
            %
            proj = projection([1,1,0],[1,-1,0]);
            pos = [1,1,0];
            zone1=[1,-1,0];
            data_source = fullfile(this.testdir,'w3d_sqw.sqw');
            outdir  = tempdir;
            outfile = fullfile(outdir ,'HoracePartialZoneN1_file_partN0.tmp');
            cob = onCleanup(@()delete(outfile));
            range1 = qe_range(-0.1,0.025,0.1);
            ranges = [range1,range1,qe_range(-Inf,Inf),qe_range(0,1.5,100)];
            ranges(1).center = zone1(1);
            ranges(2).center = zone1(2);
            ranges(3).center = zone1(3);
            
            
            
            job_par_fun = @(id,x,y)(combine_equivalent_zones_job.param_f(...
                id,x,y(1),y(2),y(3),y(4),proj,pos,data_source,outdir));
            
            
            job_param = job_par_fun(1,zone1,ranges);
            
            je = combine_equivalent_zones_job('test_sym_equiv_zones_do_job');
            je=je.do_job(job_param);
            out = je.job_outputs;
            outfile = fullfile(outdir,out.zone_files{1});
            
            assertTrue(exist(outfile,'file')==2);
            
            je.clear_all_messages();
        end
        
        
    end
end
