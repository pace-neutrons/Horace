classdef test_symm_equivalent_zones< TestCase
    %
    % Validate the dnd symmetrisation, combination and rebin routines
    
    
    % Copied from template in test_multifit_horace_1
    properties
        testdir;
        worker_h = @worker_v1
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
            
            % does not currently work -- changes for the future
            %ranges = cut_transf([-0.1,0.025,0.1],[-0.1,0.025,0.1],[-Inf,Inf],[0,1.5,100]);
            ranges = cell(2,1);
            ranges{1} = cut_transf([-0.1,0.025,0.1],[-0.1,0.025,0.1],[-Inf,Inf],[0,1.5,100]);
            ranges{2} = cut_transf([-0.1,0.025,0.1],[-0.1,0.025,0.1],[-Inf,Inf],[0,1.5,100]);
            
            ranges{1}.zone_id = 1;
            ranges{1}.zone_center = zone1;
            ranges{1}.target_center = pos;
            ranges{1} = ranges{1}.set_sigma_transf();
            %
            ranges{2}.zone_id = 2;
            ranges{2}.zone_center   = pos;
            ranges{2}.target_center = pos;
            ranges{2} = ranges{2}.set_sigma_transf();
            
            %zones = {zone1;pos};
            
            job_par_fun = @(transf)(combine_equivalent_zones_job.param_f(...
                transf,proj,data_source,outdir,2));
            
            
            % the job parameter lost to process two zones
            job_param_list  = cellfun(job_par_fun,ranges);
            
            
            jd = JobDispatcher('test_sym_equiv_zones_worker');
            mpi = jd.mess_framework;
            wk_control = mpi.build_control(1);
            mess = aMessage('starting');
            mess.payload = job_param_list;
            [ok,err] = mpi.send_message(1,mess);
            assertEqual(ok,MES_CODES.ok,sprintf('Error sending message %s',err));
            
            this.worker_h('combine_equivalent_zones_job',wk_control);
            %--------------------------
            % receive results of the work
            [ok,err,mes] = mpi.receive_message(1,'completed');
            assertEqual(ok,MES_CODES.ok,sprintf('Error sending message %s',err));
            assertTrue(isempty(err));
            res = mes.payload;
            %out = struct('zone_id',zone_id,'zone_files',[]);
            %
            mpi.finalize_all();
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
            % does not currently work -- changes for the future
            ranges = cut_transf([-0.1,0.025,0.1],[-0.1,0.025,0.1],[-Inf,Inf],[0,1.5,100]);
            
            %ranges = cut_transf([-0.1,0.025,0.1],[-0.1,0.025,0.1],[0.9,0.025,1.1],[0,1.5,100]);
            
            ranges.zone_id = 1;
            ranges.zone_center = zone1;
            ranges.target_center = pos;
            ranges = ranges.set_sigma_transf();
            
            job_par_fun = @(transf)(combine_equivalent_zones_job.param_f(...
                transf,proj,data_source,outdir,1));
            
            job_param = job_par_fun(ranges);
            job_param.n_zone = 1;
            
            
            je = combine_equivalent_zones_job('test_sym_equiv_zones_do_job');
            je=je.do_job(job_param);
            out = je.task_outputs;
            outfile = fullfile(outdir,out.zone_files{1});
            
            assertTrue(exist(outfile,'file')==2);
            
        end
        
        
    end
end
