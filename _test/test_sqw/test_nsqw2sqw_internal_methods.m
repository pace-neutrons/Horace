classdef test_nsqw2sqw_internal_methods < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tempdir();
        tests_dir;
    end
    
    methods
        function this=test_nsqw2sqw_internal_methods(name)
            if ~exist('name','var')
                name = 'test_nsqw2sqw_internal_methods';
            end
            this = this@TestCase(name);
            class_dir = fileparts(which('test_nsqw2sqw_internal_methods.m'));
            this.tests_dir = fileparts(class_dir);
        end
        %
        function test_nbin_for_pixels(obj)
            n_files = 10;
            n_bins = 41;
            npix_processed = 0;
            npix_per_bins = ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,100);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,31]);
            assertEqual(numel(npix_in_bins),31);
            %
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,200);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,21]);
            assertEqual(numel(npix_in_bins),21);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,400);
            assertEqual(size(npix_2_read),[10,20]);
            assertEqual(size(npix_per_bins),[10,1]);
            assertEqual(numel(npix_in_bins),1);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,410);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,0]);
            assertTrue(isempty(npix_in_bins));
            %--------------------------------------------------------------
            
            npix_per_bins = 10*ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            npix_processed = 0;
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,100);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,40]);
            assertEqual(numel(npix_in_bins),40);
            
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,200);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            
            npix_per_bins = 11*npix_per_bins;
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,300);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),100);
            assertEqual(npix_2_read(2),0);
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,400);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),10);
            assertEqual(npix_2_read(2),90);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins] = combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,500);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),0);
            assertEqual(npix_2_read(2),20);
            assertEqual(npix_2_read(3),80);
            assertEqual(npix_2_read(4),0);
        end
        
        function test_read_pix(obj)
            
            n_files = 10;
            fid = 1:n_files;
            run_label = 2*(1:n_files);
            pos_pixstart = zeros(n_files,1);
            npix_per_bin = randi(10,n_files,5)-1;
            filenums = 1:10;
            
            rd =combine_sqw_job_tester();
            [pix_section,pos_pixstart]=rd.read_pix_for_nbins_block(...
                fid,pos_pixstart,npix_per_bin,filenums,run_label,true,false);
            
            assertEqual( pos_pixstart,sum(npix_per_bin,2));
            assertEqual(size(pix_section),[9,sum(sum(npix_per_bin))]);
            %assertEqual(size(pix_section{2}),[9,sum(npix_per_bin(:,2))]);            
            %assertEqual(size(pix_section{3}),[9,sum(npix_per_bin(:,3))]);                        
        end
        function   xest_do_combine_sqw_pix_job(obj)
            mis = MPI_State.instance('clear');
            mis.is_tested = true;
            mis.is_deployed = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            obj= build_test_files(obj);
            
            
            [~,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            efix=efix(1:2);
            psi=psi(1:2);
            omega=omega(1);
            dpsi = dpsi(1);
            gl = gl(1);
            gs = gs(1);
            
            tmp_files=gen_sqw (obj.spe_file(1:2), '', 'dummy', efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs,'tmp_only');
            clof = onCleanup(@()(obj.delete_files(tmp_files)));

            
            serverfbMPI  = MessagesFilebased('combine_sqw_pix_job');
            serverfbMPI.mess_exchange_folder = tempdir();
            clob1 = onCleanup(@()finalize_all(serverfbMPI));
            
            
            css1= serverfbMPI.gen_worker_init(1,2);
            css2= serverfbMPI.gen_worker_init(2,2);            
            % create response filebased framework as would on worker
            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css2);            
            fbMPI2 = MessagesFilebased(control_struct);            
            
            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,1);
            je = gen_sqw_files_job();
            je = je.init(fbMPI,control_struct,init_mess{1});
            
            mis.logger = @(step,n_steps,time,add_info)...
                (je.log_progress(step,n_steps,time,add_info));
            
            
            [ok,err]=serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            
            je.do_job();
            
            assertTrue(exist(tmp_file,'file')==2);
            [ok,err]=serverfbMPI.receive_message(1,'running');
            assertEqual(ok,MESS_CODES.ok,err);
            
        end        
        
    end
end
