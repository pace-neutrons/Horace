classdef test_split< TestCase
    %
    % Validate sqw object splitting
    %

    properties
        this_dir;
        sqw_source = 'sqw_4d.sqw'

        source_sqw4D;
    end

    methods
        function obj=test_split(name)
            if ~exist('name','var')
                name = 'test_split';
            end
            obj=obj@TestCase(name);
            hpc = horace_paths;
            obj.this_dir = fileparts(mfilename('fullpath'));
            source_data = fullfile(hpc.test_common,obj.sqw_source);
            obj.sqw_source   = source_data;
            obj.source_sqw4D = read_sqw(source_data);

        end
        function delete_subfiles(~,filelist)
            for i=1:numel(filelist)
                if isfile(filelist{i})
                    del_memmapfile_files(filelist{i})
                end
            end
        end
        function test_split_all_filebacked_mem_constrained_eq_membased(obj)
            w_spl_mem = split(obj.source_sqw4D);


            img_size = obj.source_sqw4D.img_size_bytes();
            phys_mem_req = img_size*23/3; % assume only 1/3 of all split
            % images may fit memory
            clWarn = set_temporary_warning('off', ...
                'HORACE:insufficient_physical_memory','HORACE:physical_memory_configured');
            clConf = set_temporary_config_options(hpc_config, ...
                'phys_mem_available',phys_mem_req );
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            targ_folder = fullfile(tmp_dir,'split_fb_targ');
            clFiles     = onCleanup(@()rmdir(targ_folder,'s'));

            w_splf = split(source,'-files',targ_folder);

            assertEqual(numel(w_splf),23);

            % check that resulting object exist and always available
            for i=1:numel(w_splf)
                assertTrue(isfile(w_splf{i}));
                spl_obj = read_sqw(w_splf{i});
                assertEqualToTol(w_spl_mem(i),spl_obj,'ignore_str',true, ...
                    '-ignore_date','tol',[8*eps('single'),8*eps('single')]);
            end
            % restore config first to avoid warning about phys_mem_configured
            clear clConf
        end

        function test_split_all_filebacked_eq_membased(obj)
            w_spl_mem = split(obj.source_sqw4D);

            n_pix = obj.source_sqw4D.npixels;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            targ_folder = fullfile(tmp_dir,'split_fb_targ');
            clFiles     = onCleanup(@()rmdir(targ_folder,'s'));

            w_splf = split(source,'-files',targ_folder);

            assertEqual(numel(w_splf),23);

            % check that resulting object exist and always available
            for i=1:numel(w_splf)
                assertTrue(isfile(w_splf{i}));
                spl_obj = read_sqw(w_splf{i});
                assertEqualToTol(w_spl_mem(i),spl_obj,'ignore_str',true, ...
                    '-ignore_date','tol',[8*eps('single'),8*eps('single')]);
            end
        end

        function test_split_all_filebacked_generates_files(obj)
            n_pix = obj.source_sqw4D.npixels;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            hc = hor_config;
            wkdir = hc.working_directory;
            [~,fb] = fileparts(obj.source_sqw4D.full_filename);
            tf = cell(1,23);
            for i=1:23
                tf{i} = fullfile(wkdir,sprintf('%s_runID%07d.sqw',fb,91+i));
            end
            clOuF = onCleanup(@()delete_subfiles(obj,tf));

            w_splf = split(source,'-files');

            assertEqual(numel(w_splf),23);

            % check that resulting object exist and always available
            for i=1:numel(w_splf)
                assertTrue(isfile(w_splf{i}));
                assertEqual(tf{i},w_splf{i});
            end

            clear clOuF;

            for i=1:numel(w_splf)
                assertFalse(isfile(w_splf{i}));
            end
        end

        function test_split_pix_filebacked_permanent_res(obj)
            n_pix = obj.source_sqw4D.npixels;

            targ_folder = fullfile(tmp_dir,'split_fb_targ');
            clFiles = onCleanup(@()rmdir(targ_folder,'s'));
            w_spl = split(obj.source_sqw4D,'-filebacked',targ_folder);

            assertEqual(numel(w_spl),23);

            n_split_pix = 0;
            for i=1:numel(w_spl)
                assertTrue(w_spl(i).is_filebacked);
                keys = w_spl(i).runid_map.keys;
                assertEqual(numel(keys),1);
                id = unique(w_spl(i).pix.run_idx);
                assertEqual(keys{1},id);
                assertEqual(w_spl(i).experiment_info.expdata.run_id,id);
                n_split_pix  = n_split_pix +w_spl(i).npixels;
            end
            assertEqual(n_pix,n_split_pix);

            assertTrue(isfolder(targ_folder));

            % check that filebacked objects are temporary objects in this
            % case
            files = cell(1,numel(w_spl));
            for i=1:numel(files)
                files{i} = w_spl(i).full_filename;

                assertTrue(isfile(files{i}));
                [~,~,fe] = fileparts(files{i});
                assertEqual(fe,'.sqw');
            end
            clear('w_spl');
            for i=1:numel(files)
                assertTrue(isfile(files{i}));
            end
        end


        function test_split_filebacked_eq_split_membased(obj)

            w_spl_mem = split(obj.source_sqw4D);

            n_pix = obj.source_sqw4D.npixels;

            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            w_spl_fb = split(source,'-filebacked');

            assertEqual(numel(w_spl_mem),23);
            clear clConf


            for i=1:numel(w_spl_mem)
                assertEqualToTol(w_spl_mem(i),w_spl_fb(i),'ignore_str',true, ...
                    'tol',[8*eps('single'),8*eps('single')]);
            end
        end

        function test_split_pix_filebacked(obj)
            n_pix = obj.source_sqw4D.npixels;
            clConf = set_temporary_config_options(hor_config,'mem_chunk_size',n_pix/3);
            source = sqw(obj.sqw_source,'file_backed',true);
            assertTrue(source.is_filebacked);

            w_spl = split(source,'-filebacked');

            assertEqual(numel(w_spl),23);

            n_split_pix = 0;
            for i=1:numel(w_spl)
                assertTrue(w_spl(i).is_filebacked);
                keys = w_spl(i).runid_map.keys;
                assertEqual(numel(keys),1);
                id = unique(w_spl(i).pix.run_idx);
                assertEqual(keys{1},id);
                assertEqual(w_spl(i).experiment_info.expdata.run_id,id);
                n_split_pix  = n_split_pix +w_spl(i).npixels;
            end
            assertEqual(n_pix,n_split_pix);

            % check that filebacked objects are temporary objects in this
            % case
            files = cell(1,numel(w_spl));
            for i=1:numel(files)
                files{i} = w_spl(i).pix.full_filename;
                assertTrue(isfile(files{i}));
            end
            clear('w_spl');
            for i=1:numel(files)
                assertFalse(isfile(files{i}));
            end
        end

        function test_split_all_in_memory(obj)
            n_pix = obj.source_sqw4D.npixels;

            w_spl = split(obj.source_sqw4D);

            assertEqual(numel(w_spl),23);

            n_split_pix = 0;
            for i=1:numel(w_spl)
                keys = w_spl(i).runid_map.keys;
                assertEqual(numel(keys),1);
                id = unique(w_spl(i).pix.run_idx);
                assertEqual(keys{1},id);
                assertEqual(w_spl(i).experiment_info.expdata.run_id,id);
                n_split_pix  = n_split_pix +w_spl(i).npixels;
            end
            assertEqual(n_pix,n_split_pix);
        end

        function test_prepare_split_sqw_in_mem(obj)
            page_op = PageOp_split_sqw_tester();

            page_op = page_op.prepare_split_sqw_public(obj.source_sqw4D,false,false);
            n_runs  = obj.source_sqw4D.main_header.nfiles;

            assertEqual(numel(page_op.out_img),n_runs )
            assertEqual(numel(page_op.out_pix),n_runs )
            assertEqual(numel(page_op.write_handles),n_runs )
            % all memory-based objects
            is_mb  = cellfun(@isempty,page_op.write_handles);
            assertTrue(all(is_mb))
        end
    end
    methods

        function test_target_filenames_img_filebacked_with_folder_are_sqw(~)
            tc = PageOp_split_sqw_tester();
            tc.img_filebacked = true;
            tc.outfile = 'some_folder_to_place_files';

            tc = tc.gen_target_filenames_public('My_sqw_file',true);

            assertFalse(tc.results_are_tmp_files)

            file = tc.targ_files_list(101);
            [fp,fn,fe] = fileparts(file);
            assertEqual(fp,'some_folder_to_place_files')
            assertEqual(fn,'My_sqw_file_runID0000101')
            assertTrue(strcmp(fe,'.sqw'));
        end

        function test_target_filenames_img_filebacked_are_sqw(~)
            tc = PageOp_split_sqw_tester();
            tc.img_filebacked = true;

            tc = tc.gen_target_filenames_public('My_sqw_file',true);

            assertFalse(tc.results_are_tmp_files)
            hc = hor_config;
            wk_dir = hc.working_directory;
            wk_dir = regexprep(wk_dir,'[/\\]+$','');

            file = tc.targ_files_list(101);
            [fp,fn,fe] = fileparts(file);
            assertEqual(fp,wk_dir) %
            assertEqual(fn,'My_sqw_file_runID0000101')
            assertTrue(strcmp(fe,'.sqw'));
        end

        function test_target_filenames_pix_filebacked_with_folder_are_sqw(~)
            tc = PageOp_split_sqw_tester();
            tc.outfile = 'some_folder_to_place_files';

            tc = tc.gen_target_filenames_public('My_sqw_file',true);

            assertFalse(tc.results_are_tmp_files)
            file = tc.targ_files_list(101);
            [fp,fn,fe] = fileparts(file);
            assertEqual(fp,'some_folder_to_place_files')
            assertEqual(fn,'My_sqw_file_runID0000101')
            assertTrue(strcmp(fe,'.sqw'));
        end

        function test_target_filenames_pix_filebacked_are_tmp(~)
            tc = PageOp_split_sqw_tester();
            tc = tc.gen_target_filenames_public('My_sqw_file',true);

            hc = hor_config;
            wk_dir = hc.working_directory;
            wk_dir = regexprep(wk_dir,'[/\\]+$','');
            assertTrue(tc.results_are_tmp_files)
            file = tc.targ_files_list(101);
            [fp,fn,fe] = fileparts(file);
            assertEqual(fp,wk_dir) %
            assertEqual(fn,'My_sqw_file_runID0000101')
            assertTrue(strncmp(fe,'.tmp_',5));
        end

        function test_target_filenames_all_memory(~)
            tc = PageOp_split_sqw_tester();
            tc = tc.gen_target_filenames_public('My_sqw_file',false);

            hc = hor_config;
            wk_dir = hc.working_directory;
            wk_dir = regexprep(wk_dir,'[/\\]+$','');
            assertTrue(tc.results_are_tmp_files)
            file = tc.targ_files_list(101);
            [fp,fn,fe] = fileparts(file); %
            assertEqual(fp,wk_dir)
            assertEqual(fn,'My_sqw_file_runID0000101')
            assertTrue(strncmp(fe,'.tmp',4));
        end
    end
end
