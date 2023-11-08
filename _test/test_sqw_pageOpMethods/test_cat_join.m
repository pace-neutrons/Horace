classdef test_cat_join < TestCase
    properties

        SMALL_PG_SIZE = 1e5;  % 10,000 pix
        ALL_IN_MEM_PG_SIZE = 1e12;

        raw_pix_data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, 10);
        raw_pix_range;
        tst_sqw_file_full_path = '';
        this_dir = fileparts(mfilename('fullpath'));

        pixel_data_obj;
        pix_data_from_file;
        pix_data_from_faccess;
        pix_fields = {'u1', 'u2', 'u3', 'dE', 'coordinates', 'q_coordinates', ...
            'run_idx', 'detector_idx', 'energy_idx', 'signal', ...
            'variance'};

        warning_cache;
        working_test_file
    end

    properties (Constant)
        NUM_BYTES_IN_VALUE = sqw_binfile_common.FILE_PIX_SIZE;
        NUM_COLS_IN_PIX_BLOCK = PixelDataBase.DEFAULT_NUM_PIX_FIELDS;
        BYTES_IN_PIXEL = sqw_binfile_common.FILE_PIX_SIZE;
        RUN_IDX = 5;
        SIGNAL_IDX = 8;
        VARIANCE_IDX = 9;
        tol = 1e-6;
    end

    methods

        function obj = test_cat_join(~)
            obj = obj@TestCase('test_cat_join');
            obj.warning_cache = warning('off','HORACE:old_file_format');

            obj.raw_pix_range = obj.get_ref_range(obj.raw_pix_data);

            pths = horace_paths;
            source_sqw_file = fullfile(pths.test_common, 'sqw_1d_1.sqw');

            test_sqw_file_full_path = fullfile(tmp_dir, 'sqw_1d_1.sqw');
            copyfile(source_sqw_file,test_sqw_file_full_path);

            %modify_pix_ranges(test_sqw_file_full_path);
            obj.tst_sqw_file_full_path = test_sqw_file_full_path;

            % Construct an object from raw data
            obj.pixel_data_obj = PixelDataBase.create(obj.raw_pix_data);
            % Construct an object from a file
            obj.pix_data_from_file = PixelDataFileBacked(obj.tst_sqw_file_full_path);
            % Construct an object from a file accessor
            f_accessor = sqw_formats_factory.instance().get_loader(obj.tst_sqw_file_full_path);
            obj.pix_data_from_faccess = PixelDataFileBacked(f_accessor);
            % Construct an object from file accessor with small page size

        end
        function test_cat_combines_given_PixelData_objects(obj)
            pix_data_obj1 = obj.get_random_pix_data_(10);
            pix_data_obj2 = obj.get_random_pix_data_(5);

            combined_pix = pix_data_obj1.cat(pix_data_obj2);

            assertEqual(combined_pix.num_pixels, 15);
            assertEqual(combined_pix.data, ...
                horzcat(pix_data_obj1.data, pix_data_obj2.data));
        end


        function delete(obj)
            warning(obj.warning_cache);
            del_memmapfile_files(obj.tst_sqw_file_full_path);
        end
    end

    % -- Helpers --
    methods(Static, Access=private)
        function [dir1,dir2] = unify_directories(dir1,dir2)
            % helper function which would make the folders look similar
            % regardless of the presence of filesep symbol at the end
            if ispc
                eolr_sym = '\$';
            else
                eolr_sym = '$';
            end
            dir1 = regexprep(dir1,[filesep,eolr_sym],'');
            dir2 = regexprep(dir2,[filesep,eolr_sym],'');

        end

        function [pix_data,data_range] = get_random_pix_data_(rows)
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS, rows);
            pix_data = PixelDataMemory(data);
            data_range = pix_data.data_range;

        end

        function ref_range = get_ref_range(data)
            ref_range = [min(data(1:4, :),[],2),...
                max(data(1:4, :),[],2)]';
        end
        function do_pixel_data_loop_with_f(obj, func, data)
            % func should be a function handle, it is evaluated within a
            % while-advance block over some pixel data

            npix_in_page = 11;
            [pix, ~, clob] = get_pix_with_fake_faccess(data, npix_in_page);

            func(pix, 0);
            for i = 1:pix.num_pages
                pix.page_number = i;
                func(pix, i);
            end
        end
        function clear_config(obj,hc)
            if ~isempty(obj.initial_mem_chunk_size)
                hc.mem_chunk_size = obj.initial_mem_chunk_size;
            end
        end
    end
end
