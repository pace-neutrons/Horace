classdef test_sqw_constructor < TestCase & common_sqw_class_state_holder

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';

        test_sqw_1d_fullpath = '';
        test_dir;

        mem_chunk_size;
    end

    properties(Constant)
        data_npix = 100337;
    end

    methods

        function obj = test_sqw_constructor(~)
            obj = obj@TestCase('test_sqw_constructor');

            hc = hor_config;
            obj.mem_chunk_size = hc.mem_chunk_size;

            pths = horace_paths;

            obj.test_sqw_1d_fullpath = fullfile(pths.test_common, obj.sqw_file_1d_name);
            obj.test_dir = fileparts(mfilename('fullpath'));

        end

        function test_sqw_class_follows_expected_class_hierarchy(~)
            sqw_obj = sqw();

            assertTrue(isa(sqw_obj, 'sqw'));
            assertTrue(isa(sqw_obj, 'SQWDnDBase'));
        end

        function setUp(~)
            set(hor_config,'mem_chunk_size',1e6);
        end

        function tearDown(obj)
            set(hor_config,'mem_chunk_size',obj.mem_chunk_size);
        end

        function test_default_constructor_returns_empty_instance(~)
            sqw_obj = sqw();

            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqual(sqw_obj.main_header, main_header_cl());
            assertTrue(isa(sqw_obj.experiment_info, 'Experiment'));

            assertTrue((sqw_obj.experiment_info.instruments.n_runs==0));
            function throwinst()
                sqw_obj.experiment_info.instruments{1};
            end
            assertExceptionThrown( @throwinst,'HERBERT:unique_references_container:invalid_argument');
            assertTrue((sqw_obj.experiment_info.samples.n_runs==0));
            function throwsamp()
                sqw_obj.experiment_info.samples{1};
            end
            assertExceptionThrown( @throwsamp,'HERBERT:unique_references_container:invalid_argument');
            assertEqual(sqw_obj.detpar, struct([]));
            assertEqual(sqw_obj.pix, PixelDataBase.create());
            assertEqual(numel(sqw_obj.data.pax), 0);
        end

        function test_filename_constructor_returns_populated_class(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);

            % expected data populated from instance of test object
            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqual(sqw_obj.main_header.nfiles, 14)
            assertEqual(numel(sqw_obj.experiment_info.expdata), 14)
            assertEqual(sqw_obj.experiment_info.instruments.n_runs, 14)
            assertEqual(sqw_obj.experiment_info.samples.n_runs, 14)
            assertEqual(numel(sqw_obj.detpar.group), 36864);
            assertEqual(numel(sqw_obj.data.pax), 1);
            assertEqual(sqw_obj.pix.num_pixels, obj.data_npix);
        end

        function test_filename_constructor_sets_pixel_page_size_if_passed(obj)
            hc = hor_config;
            pagesize_pixels = 6666; % test value
            hc.mem_chunk_size = pagesize_pixels;

            sqw_obj = sqw(obj.test_sqw_1d_fullpath, ...
                'file_backed',true);

            assertTrue(isa(sqw_obj, 'sqw'));
            assertTrue(sqw_obj.pix.num_pixels > pagesize_pixels);
            assertEqual(sqw_obj.pix.num_pixels, obj.data_npix); % expected value from test file
            assertEqual(sqw_obj.pix.page_size, pagesize_pixels);
        end

        function test_filename_constructor_sets_all_data_default_pagesize(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);

            hc = hor_config;
            mmc = hc.mem_chunk_size;

            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqual(sqw_obj.pix.num_pixels, obj.data_npix); % expected value from test file
            assertEqual(sqw_obj.pix.page_size, min(mmc, obj.data_npix));
        end

        function test_copy_constructor_clones_object(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            sqw_copy = sqw(sqw_obj);

            assertTrue(isa(sqw_obj, 'sqw'));
            assertEqualToTol(sqw_copy, sqw_obj);
        end

        function test_save_load_returns_identical_object(obj)
            tmp_filename=fullfile(tmp_dir, 'sqw_loadobj_test.mat');
            cleanup_obj=onCleanup(@() delete(tmp_filename));

            sqw_obj = read_sqw(obj.test_sqw_1d_fullpath);
            keys = sqw_obj.runid_map.keys;
            keys = [keys{:}];
            ids = sqw_obj.experiment_info.expdata.get_run_ids();
            assertEqual(keys,ids);

            pix_ids = unique(sqw_obj.pix.get_fields('run_idx', 'all'));
            assertEqual(ids,pix_ids)

            save(tmp_filename, 'sqw_obj');
            from_file = load(tmp_filename);
            mat_stored_new = from_file.sqw_obj; % expand variable into full
            % variable with name to provide assertEqual with the variable
            % name
            assertEqualToTol(mat_stored_new, sqw_obj,[1.e-15,1.e-15],'-ignore_date');

            old_file = fullfile(obj.test_dir,'data','sqw_loadobj_test_v3_6_1.mat');
            from_file = load(old_file);
            mat_stored_old = from_file.sqw_obj;
            % old and new sqw object define img_range slightly differently
            mat_stored_old.data.axes.img_range = sqw_obj.data.img_range;
            assertEqualToTol(mat_stored_old, sqw_obj,[1.e-15,1.e-15], ...
                'ignore_str',true,'-ignore_date');
        end
        %------------------------------------------------------------------
        function test_init_from_file_loader_membacked(obj)       
            ld = sqw_formats_factory.instance().get_loader(obj.test_sqw_1d_fullpath);
            in_data = struct('file',ld, ...
                'file_backed',false,'force_pix_location',true);
            so = sqw_tester();
            so = so.init_from_file_public(in_data);
            assertTrue(isa(so.pix,'PixelDataMemory'));

        end
        
        function test_init_from_file_force_filebacked(obj)       
            in_data = struct('file',obj.test_sqw_1d_fullpath, ...
                'file_backed',true,'force_pix_location',true);
            so = sqw_tester();
            so = so.init_from_file_public(in_data);
            assertTrue(isa(so.pix,'PixelDataFileBacked'));
        end

        %------------------------------------------------------------------
        function test_input_args_filebacked_specified_false(obj)
            args = sqw_tester.parse_sqw_args_public( ...
                obj.test_sqw_1d_fullpath,'file_backed',false);
            assertTrue(args.force_pix_location)
            assertFalse(args.file_backed)
        end        
        function test_input_args_filebacked_specified_true(obj)
            args = sqw_tester.parse_sqw_args_public( ...
                obj.test_sqw_1d_fullpath,'file_backed',true);
            assertTrue(args.force_pix_location)
            assertTrue(args.file_backed)
        end
        function test_input_args_filebacked_default(~)
            args = sqw_tester.parse_sqw_args_public();
            assertFalse(args.force_pix_location)
            assertFalse(args.file_backed)
        end
    end
end