classdef test_nsqw2sqw_combine_job < TestCase & common_state_holder
    % Series of tests to check write_nsqw_to_sqw combining

    properties
        out_dir=tmp_dir();

        test_sample_file % file produced in serial to compare test against
        test_souce_files; % test files used for combining
        test_targ_file    % target file to generate for validation
        this_tests_dir;
        cleanup_obl;
    end

    methods
        function obj=test_nsqw2sqw_combine_job(name)
            if ~exist('name','var')
                name = 'test_nsqw2sqw_combine_job';
            end
            obj = obj@TestCase(name);
            class_dir = fileparts(which('test_nsqw2sqw_combine_job.m'));
            obj.this_tests_dir = fileparts(class_dir);

            source_test_dir = fullfile(horace_root(),'_test','common_data');
            source_file = fullfile(source_test_dir,'MAP11014.nxspe');

            psi = [0,2,20]; %-- test settings;
            %psi = 0:1:200;  %-- evaluate_performance settings;
            source_test_file  = cell(1,numel(psi));
            for i=1:numel(psi)
                source_test_file{i}  = source_file;
            end


            wk_dir = tmp_dir;
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
        %
        function [pix_comb,pix_out_pos]=get_pix_comb_info(obj)
            %
            infiles = obj.test_souce_files;

            [main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
                accumulate_headers_job.read_input_headers(infiles);

            [header_combined,nspe] = Experiment.combine_experiments(header,true,false);
            %headers_array(i).filename=fullfile(headers{i}.filepath,headers{i}.filename)
            %[header_combined,nspe] = sqw_header.header_combine(header,true,false);
            nfiles = sum(nspe);

            img_db_range=datahdr{1}.img_range;
            for i=2:nfiles
                img_db_range=[min(img_db_range(1,:),datahdr{i}.img_range(1,:));max(img_db_range(2,:),datahdr{i}.img_range(2,:))];
            end
            [s_accum,e_accum,npix_accum] = accumulate_headers_job.accumulate_headers(ldrs);
            [s_accum,e_accum] = normalize_signal(s_accum,e_accum,npix_accum);
            %

            main_header_combined = struct();
            main_header_combined.filename='';
            main_header_combined.filepath='';
            main_header_combined.title='';
            main_header_combined.nfiles=nfiles;

            % fill in data_sqw_dnd. Should be done in constructor, but too many
            % inputs.
            sqw_data = data_sqw_dnd(datahdr{1});
            sqw_data.filename=main_header_combined.filename;
            sqw_data.filepath=main_header_combined.filepath;
            sqw_data.title=main_header_combined.title;
            sqw_data.img_range=img_db_range;

            sqw_data.s=s_accum;
            sqw_data.e=e_accum;
            sqw_data.npix=uint64(npix_accum);


            run_label = 0:nfiles-1;
            pix_comb = pix_combine_info(infiles,numel(sqw_data.npix),pos_npixstart,pos_pixstart,npixtot,run_label);
            pix_comb.pix_range = img_db_range;
            sqw_data.pix = pix_comb;
            [fp,fn,fe] = fileparts(obj.test_targ_file);
            main_header_combined.filename = [fn,fe];
            main_header_combined.filepath = [fp,filesep];


            data_sum= struct('main_header',main_header_combined,...
                'experiment_info',[],'detpar',det);
            data_sum.data = sqw_data;
            data_sum.experiment_info = header_combined;


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
        function   test_do_combine_sqw_pix_write_separate_job(obj)
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

            serverfbMPI  = MessagesFilebased('combine_sqw_pix_write_separate_job');
            serverfbMPI.mess_exchange_folder = tmp_dir();
            clob2 = onCleanup(@()finalize_all(serverfbMPI));

            fout_name = obj.test_targ_file;
            clob3 = onCleanup(@()delete(fout_name ));
            % this is the main part of write_nsqw_procedure, and actually
            % should be taken from there
            [pix_comb_info,pix_out_pos] = obj.get_pix_comb_info();


            [common_par,loop_par ] = ...
                combine_sqw_pix_job.pack_job_pars(...
                pix_comb_info,fout_name,pix_out_pos,4,2);

            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,4);
            css2= serverfbMPI.get_worker_init('MessagesFilebased',2,4);
            css3= serverfbMPI.get_worker_init('MessagesFilebased',3,4);
            css4= serverfbMPI.get_worker_init('MessagesFilebased',4,4);
            % create response filebased framework as would on worker
            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css2);
            fbMPI2 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css3);
            fbMPI3 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css4);
            fbMPI4 = MessagesFilebased(control_struct);


            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,4);

            je1 = combine_sqw_pix_job();
            je4 = je1.init(fbMPI4,fbMPI4,init_mess{4});
            je3 = je1.init(fbMPI3,fbMPI3,init_mess{3});
            je2 = je1.init(fbMPI2,fbMPI2,init_mess{2});
            je1 = je1.init(fbMPI1,fbMPI1,init_mess{1});

            mis.logger = @(step,n_steps,time,add_info)...
                (je1.log_progress(step,n_steps,time,add_info));

            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertTrue(strcmp(mess.mess_name,'started'));

            while ~je1.is_completed()
                je4.do_job();
                je4=je4.reduce_data();
                je3.do_job();
                je3=je3.reduce_data();
                je2.do_job();
                je2=je2.reduce_data();
                je1.do_job();
                je1=je1.reduce_data();
            end

            assertTrue(je1.is_completed);
            assertTrue(exist(fout_name,'file')==2);
            [ok,err]=serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);

            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-1,0.1,5],[-0.4,0.4],[-0.4,0.4],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-0.4,0.4],[-6.5,0.3,6.5],[-0.4,0.4],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-0.4,0.4],[-0.4,0.4],[-6.5,0.3,6.5],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-0.4,0.4],[-0.4,0.4],[-0.4,0.4],[2,5,145]);
            assertTrue(ok,mess);

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
            serverfbMPI.mess_exchange_folder = tmp_dir();
            clob2 = onCleanup(@()finalize_all(serverfbMPI));

            fout_name = obj.test_targ_file;
            clob3 = onCleanup(@()delete(fout_name ));
            % this is the main part of write_nsqw_procedure, and actually
            % should be taken from there
            [pix_comb_info,pix_out_pos] = obj.get_pix_comb_info();

            [common_par,loop_par ] = ...
                combine_sqw_pix_job.pack_job_pars(pix_comb_info,fout_name,pix_out_pos,3);

            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,3);
            css2= serverfbMPI.get_worker_init('MessagesFilebased',2,3);
            css3= serverfbMPI.get_worker_init('MessagesFilebased',3,3);
            % create response filebased framework as would on worker
            control_struct = iMessagesFramework.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css2);
            fbMPI2 = MessagesFilebased(control_struct);
            control_struct = iMessagesFramework.deserialize_par(css3);
            fbMPI3 = MessagesFilebased(control_struct);

            [task_id_list,init_mess]=JobDispatcher.split_tasks(common_par,loop_par,true,3);

            je1 = combine_sqw_pix_job();
            je3 = je1.init(fbMPI3,fbMPI3,init_mess{3});
            je2 = je1.init(fbMPI2,fbMPI2,init_mess{2});
            je1 = je1.init(fbMPI1,fbMPI1,init_mess{1});

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
            [ok,err]=serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);

            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-1,0.1,5],[-0.4,0.4],[-0.4,0.4],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-0.4,0.4],[-6.5,0.3,6.5],[-0.4,0.4],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-0.4,0.4],[-0.4,0.4],[-6.5,0.3,6.5],[10,20]);
            assertTrue(ok,mess);
            [ok,mess] = is_cut_equal(obj.test_sample_file,fout_name, ...
                ortho_proj,[-0.4,0.4],[-0.4,0.4],[-0.4,0.4],[2,5,145]);
            assertTrue(ok,mess);

        end
        %
        function test_pix_cache_unbalanced_bins(~,varargin)
            % testing the situation that push/pop sorts messages by bins
            % partial messages remain at the end
            n_files  = 5;
            n_pixels = 5000;

            n_bins   = 100;
            for i=1:100
                fmp = fake_mess_provider(n_pixels,n_bins,...
                    n_files,100);
                if nargin>1
                    fmp.pix_block  = varargin{1};
                    fmp.file_blocks    = varargin{2};
                else
                    fl_blck = fmp.file_blocks{2};
                    % lets assume that file 2 contains only bins 2 and 3
                    fl_blck(1,:) = floor(2+2*rand(1,size(fl_blck,2)));
                    [~,ind] = sort(fl_blck(1,:));
                    fl_blck = fl_blck(:,ind);
                    % synchronize initial data with the modified data
                    px_blck = fmp.pix_block;
                    px_blck(:,fl_blck(3,:)) = fl_blck;
                    fmp.file_blocks{2} = fl_blck;
                    [~,ind] = sort(px_blck(1,:));
                    fmp.pix_block = px_blck(:,ind);
                end

                mess_list = fmp.receive_all();

                pc = pix_cache(n_files,n_bins);
                [pc,npix_received] =pc.push_messages(mess_list);
                assertEqual(pc.npix_in_cache,100*n_files);
                npix_in_cache = pc.npix_in_cache;


                pb = [];
                npr = npix_received;
                data_sources = pc.data_surces_remain();
                while ~isempty(data_sources)|| pc.npix_in_cache ~= 0
                    [pc,pix_block] = pc.pop_pixels();
                    pb = [pb,pix_block];
                    assertEqual(npix_in_cache,pc.npix_in_cache+size(pix_block,2));

                    [mess_list,task_ids] = fmp.receive_all();
                    data_sources = pc.data_surces_remain();
                    assertEqual(task_ids,data_sources');

                    [pc,npix_received] =pc.push_messages(mess_list);
                    npix_in_cache = pc.npix_in_cache;
                    npr =npr+npix_received;
                end
                assertEqual(npr,n_pixels);

                tpb = fmp.pix_block;
                assertEqual(tpb(1,:)',pb(1,:)',sprintf(' Step N %d',i));
                assertEqual(sort(tpb'),sort(pb'))
            end
        end
        %
        function test_pix_cache_sparce_bins(~,varargin)
            % testing the situation that push/pop sorts messages by bins
            % a lot of small and empty bins
            n_files  = 10;
            n_pixels = 5000;

            n_bins   = 1000;
            for i=1:100
                fmp = fake_mess_provider(n_pixels,n_bins,...
                    n_files,100);
                if nargin>1
                    fmp.pix_block  = varargin{1};
                    fmp.file_blocks    = varargin{2};
                end

                mess_list = fmp.receive_all();


                pc = pix_cache(n_files,n_bins);
                [pc,npix_received] =pc.push_messages(mess_list);
                npix_in_cache = pc.npix_in_cache;
                assertEqual(npix_in_cache,100*n_files);



                pb = [];
                npr = npix_received;
                %
                data_sources = pc.data_surces_remain();
                while ~isempty(data_sources)|| pc.npix_in_cache ~= 0

                    [pc,pix_block] = pc.pop_pixels();
                    assertEqual(npix_in_cache,pc.npix_in_cache+size(pix_block,2));

                    pb = [pb,pix_block];

                    [mess_list,task_ids] = fmp.receive_all();
                    data_sources = pc.data_surces_remain();
                    assertEqual(task_ids,data_sources');

                    [pc,npix_received] =pc.push_messages(mess_list);
                    npix_in_cache = pc.npix_in_cache;
                    npr =npr+npix_received;
                end
                assertEqual(npr,n_pixels);
                tpb = fmp.pix_block;
                assertEqual(tpb(1,:)',pb(1,:)',sprintf(' Step N %d',i));
                assertEqual(sort(tpb'),sort(pb'))
            end
        end
        %
        function test_pix_cache_parial_bins(~,varargin)
            % testing the situation that push/pop sorts messages by bins
            % all bins are usually full
            n_files  = 10;
            n_pixels = 5000;

            n_bins   = 4;
            for i=1:100
                fmp = fake_mess_provider(n_pixels,n_bins,...
                    n_files,100);
                if nargin>1
                    fmp.pix_block  = varargin{1};
                    fmp.file_blocks    = varargin{2};
                end

                mess_list = fmp.receive_all();


                pc = pix_cache(n_files,n_bins);
                [pc,npix_received] =pc.push_messages(mess_list);
                npix_in_cache = pc.npix_in_cache;
                assertEqual(npix_in_cache,100*n_files);



                pb = [];
                npr = npix_received;
                %
                data_sources = pc.data_surces_remain();
                while ~isempty(data_sources)|| pc.npix_in_cache ~= 0

                    [pc,pix_block] = pc.pop_pixels();
                    assertEqual(npix_in_cache,pc.npix_in_cache+size(pix_block,2));

                    pb = [pb,pix_block];

                    % in real life we will receive only from DS identified
                    % here
                    data_sources = pc.data_surces_remain();
                    [mess_list,task_ids] = fmp.receive_all();
                    if numel(data_sources) ~= numel(task_ids)
                        assignin('base','pix_block',fmp.pix_block);
                        assignin('base','file_blocks',fmp.file_blocks);
                    end
                    assertEqual(task_ids,data_sources');

                    [pc,npix_received] =pc.push_messages(mess_list);

                    npix_in_cache = pc.npix_in_cache;
                    npr =npr+npix_received;
                end
                assertEqual(npr,n_pixels);
                tpb = fmp.pix_block;
                assertEqual(tpb(1,:)',pb(1,:)',sprintf(' Step N %d',i));
                assertEqual(sort(tpb'),sort(pb'))
            end
        end
        %
        function test_pix_cache(~,varargin)
            % testing pixel cache for most common operations
            n_files  = 10;
            n_pixels = 4023;
            n_bins   = 100;
            for i=1:100

                fmp = fake_mess_provider(n_pixels,n_bins,...
                    n_files,1000);
                if nargin>1
                    fmp.test_pix_block  = varargin{1};
                    fmp.file_pix       = varargin{2};
                end

                mess_list = fmp.receive_all();

                nbinsp_in_pix = cellfun(@(ms)(max(ms.payload.pix_data(1,:))+1),...
                    mess_list,'UniformOutput',true);

                assertTrue(all(fmp.nbin_start>=nbinsp_in_pix));
                assertEqual(sum(fmp.npix_start),n_pixels+n_files); % npix start exceeds npixels by 1 so 1*n_files

                pc = pix_cache(n_files,n_bins);
                [pc,npix_received] =pc.push_messages(mess_list);
                assertEqual(npix_received,n_pixels);


                [pc,pix_block] = pc.pop_pixels();
                data_sources = pc.data_surces_remain();
                while ~isempty(data_sources)|| pc.npix_in_cache ~= 0
                    [pc,pix_block2] = pc.pop_pixels();
                    pix_block= [pix_block,pix_block2];
                    data_sources = pc.data_surces_remain();
                end
                tpb = fmp.pix_block;
                assertEqual(tpb(1,:)',pix_block(1,:)',sprintf(' Step N %d',i));
                assertEqual(sort(tpb'),sort(pix_block'))

                assertEqual(pc.last_bin_processed,100);
            end
        end
        %
        function test_nbin_for_pixels(~)

            rd =combine_sqw_job_tester();

            n_files = 10;
            n_bins = 41;
            npix_processed = 0;
            npix_per_bins = ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] =...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,100);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,31]);
            assertEqual(numel(npix_in_bins),31);
            assertEqual(last_fit_bin,10);
            %

            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] =...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
            assertEqual(npix_processed,200);
            assertEqual(size(npix_2_read),[10,10]);
            assertEqual(size(npix_per_bins),[10,21]);
            assertEqual(numel(npix_in_bins),21);
            assertEqual(last_fit_bin,10);


            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] =...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,400);
            assertEqual(size(npix_2_read),[10,20]);
            assertEqual(size(npix_per_bins),[10,1]);
            assertEqual(numel(npix_in_bins),1);
            assertEqual(last_fit_bin,20);

            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] = ...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,200);
            assertEqual(npix_processed,410);
            assertEqual(size(npix_2_read),[10,1]);
            assertEqual(size(npix_per_bins),[10,0]);
            assertTrue(isempty(npix_in_bins));
            assertEqual(last_fit_bin,1);
            %--------------------------------------------------------------

            npix_per_bins = 10*ones(n_files,n_bins);
            npix_in_bins = cumsum(sum(npix_per_bins,1));
            npix_processed = 0;
            [npix_2_read,npix_processed,npix_per_bins,npix_in_bins,last_fit_bin] =...
                rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,100);
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
        %
        function test_read_pix(~)

            n_files = 10;
            fid = 1:n_files;
            run_label = 2*(1:n_files);

            filenums = 1:10;

            rd =combine_sqw_job_tester();
            rd.pix_combine_info = struct('filenum',filenums,'run_label',run_label,...
                'change_fileno',true,'relabel_with_fnum',false,...
                'pos_npixstart',ones(n_files,1));
            rd.fid = fid;

            n_bins = 50;
            pix_buf_size = 2000;
            n_pixels = 100;

            for i=1:100
                pos_pixstart = ones(n_files,1);
                rd = rd.init_fake_mpi(n_files,pix_buf_size,n_pixels,n_bins);

                [npix_per_bins,npix_in_bins,ibin_end]=...
                    rd.get_npix_section(1,n_bins,pix_buf_size);
                npix_per_bins  = npix_per_bins';
                npix_processed = 0;
                assertEqual(ibin_end,n_bins);

                [npix_per_bin2_read,npix_processed,npix_per_bins,npix_in_bins,n_last_fit_bin] = ...
                    rd.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size);

                assertEqual(n_last_fit_bin,n_bins);
                assertEqual(npix_processed,n_pixels);
                assertEqual(size(npix_per_bins),[10,0]);
                assertTrue(isempty(npix_in_bins));

                [pix_section,pos_pixstart]=rd.read_pix_for_nbins_block(...
                    pos_pixstart,npix_per_bin2_read);

                assertEqual(pos_pixstart-1,sum(npix_per_bin2_read,2));
                assertEqual(size(pix_section),[9,sum(sum(npix_per_bin2_read))]);

                tpb = rd.mess_framework.pix_block;
                assertEqual(tpb(1,:)',pix_section(1,:)');
                assertEqual(sort(tpb(1:3,:)'),sort(pix_section(1:3,:)'));
            end
        end

    end
end
