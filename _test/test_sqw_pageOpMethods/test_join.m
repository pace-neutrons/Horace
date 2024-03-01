classdef test_join < TestCase
    properties
        test_dir;
        work_dir;
        sample_obj;
        sqw_to_join;
        files_to_join;
    end

    methods
        function obj = test_join(~)
            obj = obj@TestCase('test_join');
            hc = horace_paths;
            obj.test_dir = hc.test_common;
            obj.sample_obj = read_sqw(fullfile(obj.test_dir,'sqw_2d_1.sqw'));
            obj.sqw_to_join = obj.sample_obj.split();
            n_parts = numel(obj.sqw_to_join);
            obj.files_to_join = cell(n_parts,1);
            obj.work_dir   = fullfile(tmp_dir,'test_join_data');
            if ~isfolder(obj.work_dir)
                mkdir(obj.work_dir);
            end
            for i = 1:n_parts
                id = obj.sqw_to_join(i).runid_map.keys;
                [~,fn] = fileparts(obj.sqw_to_join(i).main_header.filename);
                fn = sprintf('%s_runID%d',fn,id{1});
                fn = fullfile(obj.work_dir,fn);
                obj.files_to_join{i} = fn;
                if isfile(fn)
                    continue;
                end
                save(obj.sqw_to_join(i),fn);

            end
        end
        function delete(obj)
            if ~isempty(obj.work_dir) && isfolder(obj.work_dir)
                rmdir(obj.work_dir,'s');
            end
        end

        function test_split_cube_1_run(~)
            sqw_obj = sqw.generate_cube_sqw(10);

            split_obj = split(sqw_obj);
            reformed_obj = sqw.join(sqw_obj);

            assertEqualToTol(split_obj, reformed_obj)
            assertEqualToTol(sqw_obj, reformed_obj)
        end

        function test_split_cube_2_run(~)
            sqw_obj = sqw.generate_cube_sqw(10);

            sqw_obj.pix.run_idx(8:end) = 2;

            sqw_obj.experiment_info.expdata(2) = struct( ...
                "filename", 'fake', ...
                "filepath", '/fake', ...
                "efix", 1, ...
                "emode", 1, ...
                "cu", [1,0,0], ...
                "cv", [0,1,0], ...
                "psi", 1, ...
                "omega", 1, ...
                "dpsi", 1, ...
                "gl", 1, ...
                "gs", 1, ...
                "en", 10, ...
                "run_id", 1);
            sqw_obj.main_header.nfiles = 2;

            sqw_obj.experiment_info.runid_map(2) = 2;

            split_obj = sqw_obj.split();

            assertEqual(numel(split_obj), 2)

            reformed_obj = sqw.join(split_obj,sqw_obj);

            assertEqualToTol(sqw_obj, reformed_obj,'ignore_str',true);
        end
        %------------------------------------------------------------------
        function test_join_eq_write_nsqw_to_sqw(obj)
            clHConf = set_temporary_config_options(hor_config,'use_mex',false);
            outfile = fullfile(tmp_dir,'write_nsqw_to_sqw_test_join.sqw');
            clObj = onCleanup(@()delete(outfile));
            [~,~,reformed_obj] = write_nsqw_to_sqw(obj.files_to_join,outfile,'-keep');

            % This is bug Re #1432
            reformed_obj.experiment_info.detector_arrays = obj.sample_obj.experiment_info.detector_arrays;
            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true,'-ignore_date')
            clear reformed_obj % clear it first to allow delete
            skipTest("Re #1432 detpar is not wired properly to detector_arrays")
        end
        function test_join_changes_runid_on_files_mex(obj)
            [~, ~, can_combine_with_mex] = check_horace_mex();
            if ~can_combine_with_mex
                skipTest('Combinbing with mex is not available on this system')
            end
            clWarn = set_temporary_warning('off','HORACE:physical_memory_configured');
            clHConf = set_temporary_config_options(hor_config,'use_mex',true);
            clConf = set_temporary_config_options(hpc_config,'combine_sqw_using','mex_code');

            reformed_obj = sqw.join(obj.files_to_join,'-recalc');

            runid = reformed_obj.runid_map.keys();
            assertEqual([runid{:}],1:reformed_obj.main_header.nfiles);

            sobj = obj.sample_obj;
            pix_data = sobj.pix.data;
            idx = PixelData.field_index('run_idx');
            pix_data(idx,:) = pix_data(idx,:) - 18;
            sobj.pix.data = pix_data;
            sobj.experiment_info.runid_map  = 1:numel(obj.files_to_join);

            %
            assertEqual(obj.sample_obj.detpar,reformed_obj.detpar)

            assertEqualToTol(sobj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)
            % clear configuration to avoid memory warnings
            clear clConf;
        end
        function test_join_works_with_file_list_with_mex(obj)
            [~, ~, can_combine_with_mex] = check_horace_mex();
            if ~can_combine_with_mex
                skipTest('Combinbing with mex is not available on this system')
            end
            clWarn = set_temporary_warning('off','HORACE:physical_memory_configured');
            clHConf = set_temporary_config_options(hor_config,'use_mex',true);
            clConf = set_temporary_config_options(hpc_config,'combine_sqw_using','mex_code');

            reformed_obj = sqw.join(obj.files_to_join);
            %
            assertEqual(obj.sample_obj.detpar,reformed_obj.detpar)
            % This is bug Re #1432
            reformed_obj.experiment_info.detector_arrays = obj.sample_obj.experiment_info.detector_arrays;
            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)
            % clear configuration to avoid memory warnings
            clear clConf;
            skipTest("Re #1432 detpar is not wired properly to detector_arrays")
        end

        function test_join_works_with_file_list_with_nomex_pages(obj)
            page_size = obj.sample_obj.pix.num_pixels/4;
            clWarn = set_temporary_warning('off','HOR_CONFIG:set_mem_chunk_size');
            clConf = set_temporary_config_options(hor_config,'use_mex',false, ...
                'mem_chunk_size',page_size,'fb_scale_factor',3);

            reformed_obj = sqw.join(obj.files_to_join);
            %
            assertEqual(obj.sample_obj.detpar,reformed_obj.detpar)
            reformed_obj.experiment_info.detector_arrays = obj.sample_obj.experiment_info.detector_arrays;
            % This is the issue Re #1147 should arrdess
            clear clConf;
            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)

            skipTest("Re #1432 detpar is not wired properly to detector_arrays")
            skipTest("Re #1147 Equal_to_toll does not work correctly with arbitrary pages")
        end

        function test_join_works_with_file_list_with_nomex_and_sample(obj)
            clConf = set_temporary_config_options(hor_config,'use_mex',false);

            reformed_obj = sqw.join(obj.files_to_join,obj.sample_obj);
            %
            assertEqual(obj.sample_obj.detpar,reformed_obj.detpar)
            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)
        end


        function test_join_works_with_file_list_with_nomex(obj)
            clConf = set_temporary_config_options(hor_config,'use_mex',false);

            reformed_obj = sqw.join(obj.files_to_join);
            %
            assertEqual(obj.sample_obj.detpar,reformed_obj.detpar)
            % This is bug Re #1432
            reformed_obj.experiment_info.detector_arrays = obj.sample_obj.experiment_info.detector_arrays;
            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)
            skipTest("Re #1432 detpar is not wired properly to detector_arrays")
        end
        %------------------------------------------------------------------
        function test_join_creates_tmp_filebacked_on_conditions(obj)
            page_size = obj.sample_obj.pix.num_pixels/4;
            clWarn = set_temporary_warning('off','HOR_CONFIG:set_mem_chunk_size');
            clConf = set_temporary_config_options('hor_config', ...
                'mem_chunk_size',page_size,'fb_scale_factor',3);

            nf = numel(obj.files_to_join);
            split_obj = cell(1,nf);
            for i=1:nf
                split_obj{i} = sqw(obj.files_to_join{i},'file_backed',true);
                assertTrue(split_obj{i}.is_filebacked);
            end

            reformed_obj = sqw.join(split_obj);

            assertTrue(reformed_obj.is_filebacked)
            targ_file = reformed_obj.full_filename;
            assertTrue(isfile(targ_file))
            % to compare filebacked and memory backed object properly, here
            % we need to have compatible page sizes. The comparison will
            % fail otherwise. Re #1147 -- should fix that.
            clear clConf;
            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)

            clear reformed_obj
            assertFalse(isfile(targ_file));
            skipTest("Re #1147 Equal_to_toll does not work correctly with arbitrary pages")
        end
        %
        function test_join_saves_filebacked_on_request(obj)
            targ_file = fullfile(tmp_dir,'test_join_saves_filebacked.sqw');
            clOb = onCleanup(@()delete(targ_file));

            split_obj = obj.sqw_to_join;
            reformed_obj = sqw.join(split_obj,targ_file);

            assertTrue(reformed_obj.is_filebacked)
            assertTrue(isfile(targ_file));

            assertEqual(reformed_obj.full_filename,targ_file);

            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)

            clear reformed_obj
            assertTrue(isfile(targ_file));
        end
        %------------------------------------------------------------------
        function test_join_changes_runid_on_requests_in_mem_no_sample(obj)

            split_obj = obj.sqw_to_join;

            assertTrue(all(arrayfun(@(x) x.main_header.nfiles == 1, split_obj)));

            reformed_obj = sqw.join(split_obj,'-recalc_runid');

            runid = reformed_obj.runid_map.keys();
            assertEqual([runid{:}],1:reformed_obj.main_header.nfiles);

            sobj = obj.sample_obj;
            pix_data = sobj.pix.data;
            idx = PixelData.field_index('run_idx');
            pix_data(idx,:) = pix_data(idx,:) - 18;
            sobj.pix.data = pix_data;
            sobj.experiment_info.runid_map  = 1:numel(split_obj);

            assertEqualToTol(sobj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)
        end

        function test_join_changes_runid_on_requests_in_mem_with_sample(obj)

            split_obj = obj.sqw_to_join;

            assertTrue(all(arrayfun(@(x) x.main_header.nfiles == 1, split_obj)));

            reformed_obj = sqw.join(split_obj,obj.sample_obj,'-recalc_runid');

            runid = reformed_obj.runid_map.keys();
            assertEqual([runid{:}],1:reformed_obj.main_header.nfiles);

            sobj = obj.sample_obj;
            pix_data = sobj.pix.data;
            idx = PixelData.field_index('run_idx');
            pix_data(idx,:) = pix_data(idx,:) - 18;
            sobj.pix.data = pix_data;
            sobj.experiment_info.runid_map  = 1:numel(split_obj);

            assertEqualToTol(sobj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)
        end

        function test_split_and_join_returns_same_obj_in_mem(obj)

            split_obj = obj.sqw_to_join;

            assertTrue(all(arrayfun(@(x) x.main_header.nfiles == 1, split_obj)));

            reformed_obj = sqw.join(split_obj);

            assertEqualToTol(obj.sample_obj, reformed_obj, [1e-7, 1e-7], 'ignore_str', true)
        end

        function test_collect_metadata_works_on_membased(obj)
            sqw_t = collect_sqw_metadata(obj.sqw_to_join);
            assertEqual(sqw_t.main_header.nfiles,24)

            assertEqualToTol(sqw_t.data,obj.sample_obj.data, ...
                'ignore_str',true,'tol',[1.e-7,1.e-7])
            assertTrue(isa(sqw_t.pix,'pixobj_combine_info'))
        end

        function test_collect_metadata_works_on_files(obj)
            sqw_t = collect_sqw_metadata(obj.files_to_join);
            assertEqual(sqw_t.main_header.nfiles,24)

            assertEqualToTol(sqw_t.data,obj.sample_obj.data, ...
                'ignore_str',true,'tol',[1.e-7,1.e-7])
            assertTrue(isa(sqw_t.pix,'pixfile_combine_info'))
        end
    end
end
