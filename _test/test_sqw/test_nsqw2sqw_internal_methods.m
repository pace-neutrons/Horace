classdef test_nsqw2sqw_internal_methods < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tempdir();
        
        test_sample_file % file produced in serial to compare test against
        test_souce_files; % test files used for combining
        test_targ_file    % target file to generate for validation
        this_tests_dir;
        cleanup_obl;
    end
    
    methods
        function obj=test_nsqw2sqw_internal_methods(name)
            if ~exist('name','var')
                name = 'test_nsqw2sqw_internal_methods';
            end
            obj = obj@TestCase(name);
            class_dir = fileparts(which('test_nsqw2sqw_internal_methods.m'));
            obj.this_tests_dir = fileparts(class_dir);
            her_dir = fileparts(which('herbert_init.m'));
            source_test_dir = fullfile(her_dir,'_test','common_data');
            source_file = fullfile(source_test_dir,'MAP11014.nxspe');
            
            psi = [0,2,20]; %-- test settings;
            %psi = 0:1:200;  %-- evaluate_performance settings;
            source_test_file  = cell(1,numel(psi));
            for i=1:numel(psi)
                source_test_file{i}  = source_file;
            end
            
            
            wk_dir = tempdir;
            targ_file = fullfile(wk_dir,'nsqw_2sqw_test_sample_file.sqw');
            obj.test_sample_file = targ_file;
            obj.test_targ_file = fullfile(obj.out_dir,'combine_sqw_pix_test.sqw');
            
            hc = hor_config;
            del_tmp_state = hc.delete_tmp;
            hc.delete_tmp = false;
            clob1 = onCleanup(@()set(hc,'delete_tmp',del_tmp_state));
            hpc = hpc_config;
            [comb_state,combine_sqw_using] = get(hpc,'build_sqw_in_parallel','combine_sqw_using');
            hpc.build_sqw_in_parallel = false;
            hpc.combine_sqw_using  = 'matlab';
            clob2 = onCleanup(@()set(hpc,'build_sqw_in_parallel',comb_state,'combine_sqw_using',combine_sqw_using));
            
            
            temp_files=gen_sqw(source_test_file,'',targ_file,...
                787.,1,[2.87,2.87,2.87],[90,90,90],...
                [1,0,0],[0,1,0],psi,0,0,0,0,'replicate');
            obj.test_souce_files = temp_files;
            obj.cleanup_obl = onCleanup(@()delete(temp_files{:},targ_file));
        end
        function [pix_comb,pix_out_pos]=get_pix_comb_info(obj)
            %
            infiles = obj.test_souce_files;
            
            [main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
                accumulate_headers_job.read_input_headers(infiles);
            
            [header_combined,nspe] = sqw_header.header_combine(header,true,false);
            nfiles = numel(nspe);
            
            urange=datahdr{1}.urange;
            for i=2:nfiles
                urange=[min(urange(1,:),datahdr{i}.urange(1,:));max(urange(2,:),datahdr{i}.urange(2,:))];
            end
            [s_accum,e_accum,npix_accum] = accumulate_headers_job.accumulate_headers(ldrs);
            s_accum = s_accum ./ npix_accum;
            e_accum = e_accum ./ npix_accum.^2;
            nopix=(npix_accum==0);
            s_accum(nopix)=0;
            e_accum(nopix)=0;
            %
            
            main_header_combined = struct();
            main_header_combined.filename='';
            main_header_combined.filepath='';
            main_header_combined.title='';
            main_header_combined.nfiles=nfiles;
            
            % fill in data_sqw_dnd. Should be done in constructor, but too many
            % inputs.
            sqw_data = data_sqw_dnd();
            sqw_data.filename=main_header_combined.filename;
            sqw_data.filepath=main_header_combined.filepath;
            sqw_data.title=main_header_combined.title;
            sqw_data.alatt=datahdr{1}.alatt;
            sqw_data.angdeg=datahdr{1}.angdeg;
            sqw_data.uoffset=datahdr{1}.uoffset;
            sqw_data.u_to_rlu=datahdr{1}.u_to_rlu;
            sqw_data.ulen=datahdr{1}.ulen;
            sqw_data.ulabel=datahdr{1}.ulabel;
            sqw_data.iax=datahdr{1}.iax;
            sqw_data.iint=datahdr{1}.iint;
            sqw_data.pax=datahdr{1}.pax;
            sqw_data.p=datahdr{1}.p;
            sqw_data.dax=datahdr{1}.dax;    % take the display axes from first file, for sake of choosing something
            % store urange
            sqw_data.urange=urange;
            
            sqw_data.s=s_accum;
            sqw_data.e=e_accum;
            sqw_data.npix=uint64(npix_accum);
            
            
            run_label = 0:nfiles-1;
            pix_comb = pix_combine_info(infiles,numel(sqw_data.npix),pos_npixstart,pos_pixstart,npixtot,run_label);
            sqw_data.pix = pix_comb;
            [fp,fn,fe] = fileparts(obj.test_targ_file);
            main_header_combined.filename = [fn,fe];
            main_header_combined.filepath = [fp,filesep];
            
            
            data_sum= struct('main_header',main_header_combined,...
                'header',[],'detpar',det,'data',sqw_data);
            
            
            
            data_sum.header = header_combined;
            
            ds = sqw(data_sum);
            wrtr = sqw_formats_factory.instance().get_pref_access('sqw');
            wrtr = wrtr.init(ds,obj.test_targ_file);
            % write all sqw data except pixels
            wrtr = wrtr.put_sqw('-nopix','-reserve');
            %
            pix_out_pos = wrtr.pix_position;
            wrtr.delete();
        end
        %
        function   test_do_combine_sqw_pix_job(obj)
            mis = MPI_State.instance('clear');
            mis.is_tested = true;
            mis.is_deployed = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            %
            % to make careful and consistent testing, decrease the size of the pixel
            % access buffer to make multiple IO operations
            hc = hor_config;
            pix_buf_size = hc.mem_chunk_size;
            clob1 = onCleanup(@()(set(hc,'mem_chunk_size',pix_buf_size)));
            hc.mem_chunk_size = 10000000;
            
            serverfbMPI  = MessagesFilebased('combine_sqw_pix_test_job');
            serverfbMPI.mess_exchange_folder = tempdir();
            clob2 = onCleanup(@()finalize_all(serverfbMPI));
            
            fout_name = obj.test_targ_file;
            clob3 = onCleanup(@()delete(fout_name ));
            % this is the main part of write_nsqw_procedure, and actually
            % should be taken from there
            [pix_comb_info,pix_out_pos] = obj.get_pix_comb_info();
            
            [common_par,loop_par ] = ...
                combine_sqw_pix_job.pack_job_pars(pix_comb_info,fout_name,pix_out_pos,3);
            
            css1= serverfbMPI.gen_worker_init(1,3);
            css2= serverfbMPI.gen_worker_init(2,3);
            css3= serverfbMPI.gen_worker_init(3,3);
            % create response filebased framework as would on worker
            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css2);
            fbMPI2 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css3);
            fbMPI3 = MessagesFilebased(control_struct);
            
            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,3);
            
            je1 = combine_sqw_pix_job();
            je3 = je1.init(fbMPI3,control_struct,init_mess{3});
            je2 = je1.init(fbMPI2,control_struct,init_mess{2});
            je1 = je1.init(fbMPI1,control_struct,init_mess{1});
            
            mis.logger = @(step,n_steps,time,add_info)...
                (je1.log_progress(step,n_steps,time,add_info));
            
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertTrue(strcmp(mess.mess_name,'started'));
            
            while ~je1.is_completed()
                je3.do_job();
                je3=je3.reduce_data();
                je2.do_job();
                je2=je2.reduce_data();
                je1.do_job();
                je1=je1.reduce_data();
            end
            
            assertTrue(je1.is_completed);
            assertTrue(exist(fout_name,'file')==2);
            [ok,err]=serverfbMPI.receive_message(1,'running');
            assertEqual(ok,MESS_CODES.ok,err);
            
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name,projaxes,[-1,0.1,5],[-0.4,0.4],[-0.4,0.4],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name,projaxes,[-0.4,0.4],[-6.5,0.3,6.5],[-0.4,0.4],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name,projaxes,[-0.4,0.4],[-0.4,0.4],[-6.5,0.3,6.5],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name,projaxes,[-0.4,0.4],[-0.4,0.4],[-0.4,0.4],[2,5,145]);
            assertTrue(ok,mess);
            
        end
        %
        function test_pix_cash(obj)
            n_files  = 10;
            n_pixels = 4023;
            n_bins   = 100;
            test_pix_block =  build_pix_block_for_testing(n_pixels,n_bins,n_files);
            nbin_start = 1;
            nbin_end   = 10;
            [mess_list,npix1,npix2] = split_to_messages_for_testing(test_pix_block,nbin_start,nbin_end,n_files);
            
            pc = pix_cash(n_files+1);
            pc =pc.push_messages(mess_list);
            [pc,pix_block] = pc.pop_pixels();
            
            
            assertEqual(sort(test_pix_block(:,npix1:npix2)'),sort(pix_block'))
            
            n_bins   = 1000;
            test_pix_block =  build_pix_block_for_testing(n_pixels,n_bins,n_files);
            nbin_start = 1;
            nbin_end   = 10;
            [mess_list,npix1,npix2] = split_to_messages_for_testing(test_pix_block,nbin_start,nbin_end,n_files);
            
            pc =pc.push_messages(mess_list);
            [pc,pix_block] = pc.pop_pixels();
            assertEqual(sort(test_pix_block(:,npix1:npix2)'),sort(pix_block'))            
            
%             [mess_list1,npix_l1,npix_r1] = split_to_messages_for_testing(test_pix_block,10,20,5,1:5);            
%             [mess_list2,npix_l2,npix_r2] = split_to_messages_for_testing(test_pix_block,10,15,5,6:10);                        
%             
%              mess_list = {mess_list1{:},mess_list2{:}};
%              pc =pc.push_messages(mess_list);
%              [pc,pix_block] = pc.pop_pixels();
%              assertEqual(sort(test_pix_block(:,npix_l2:npix_r2)'),sort(pix_block'))                         
%              
%              [mess_list2,npix_l2,npix_r2] = split_to_messages_for_testing(test_pix_block,16,20,5,6:10);                                     
%              mess_list1 = cell(5,1);
%              mess_list = {mess_list1{:},mess_list2{:}};
%               pc =pc.push_messages(mess_list);
%              [pc,pix_block] = pc.pop_pixels();
%              assertEqual(sort(test_pix_block(:,npix_l2:npix_r2)'),sort(pix_block'))                                       

        end
        %
        function test_nbin_for_pixels(obj)
            
            rd =combine_sqw_job_tester();
            
            n_files = 10;
            n_bins = 41;
            npix_processed = 0;
            npix_per_bins = ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,100);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,31]);
            assertEqual(numel(npix_in_bins),31);
            assertEqual(last_fit_bin,10);
            %
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,200);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,21]);
            assertEqual(numel(npix_in_bins),21);
            assertEqual(last_fit_bin,10);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,400);
            assertEqual(size(npix_2_read),[10,20]);
            assertEqual(size(npix_per_bins),[10,1]);
            assertEqual(numel(npix_in_bins),1);
            assertEqual(last_fit_bin,20);
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,410);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,0]);
            assertTrue(isempty(npix_in_bins));
            assertEqual(last_fit_bin,1);
            %--------------------------------------------------------------
            
            npix_per_bins = 10*ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            npix_processed = 0;
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,100);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,40]);
            assertEqual(numel(npix_in_bins),40);
            assertEqual(last_fit_bin,1);
            
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = ...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,200);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(last_fit_bin,1);
            
            npix_per_bins = 11*npix_per_bins;
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = ...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,300);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),100);
            assertEqual(npix_2_read(2),0);
            assertEqual(last_fit_bin,0);
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] =...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,400);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),10);
            assertEqual(npix_2_read(2),90);
            assertEqual(last_fit_bin,0);
            
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] =...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,500);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,39]);
            assertEqual(numel(npix_in_bins),39);
            assertEqual(npix_2_read(1),0);
            assertEqual(npix_2_read(2),20);
            assertEqual(npix_2_read(3),80);
            assertEqual(npix_2_read(4),0);
            assertEqual(last_fit_bin,0);
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = ...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,700);
            assertEqual(npix_processed,1300);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,38]);
            assertEqual(numel(npix_in_bins),38);
            assertEqual(npix_2_read(1),0);
            assertEqual(npix_2_read(2),0);
            assertEqual(npix_2_read(3),30);
            assertEqual(npix_2_read(4),110);
            assertEqual(last_fit_bin,1);
            
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = ...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,1200);
            assertEqual(npix_processed,2200);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,37]);
            assertEqual(numel(npix_in_bins),37);
            assertEqual(npix_2_read(1),110);
            assertEqual(npix_2_read(2),110);
            assertEqual(npix_2_read(3),110);
            assertEqual(npix_2_read(4),110);
            assertEqual(last_fit_bin,1);
            
            
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
        
    end
end
