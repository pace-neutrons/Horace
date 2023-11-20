classdef test_cat_combine < TestCase
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

        function obj = test_cat_combine(~)
            obj = obj@TestCase('test_cat_join');

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

            combined_pix = pix_data_obj1.cat(pix_data_obj1,pix_data_obj2);

            assertEqual(combined_pix.num_pixels, 15);
            assertEqual(combined_pix.data, ...
                horzcat(pix_data_obj1.data, pix_data_obj2.data));
        end
        %------------------------------------------------------------------
        function test_get_page_data_4pix_large_odd_split_chunks(~)
            n_pix = 100;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,n_pix);
            pix1 = PixelDataMemory(data(:,1:25));
            pix2 = PixelDataMemory(data(:,26:50));
            pix3 = PixelDataMemory(data(:,51:75));
            pix4 = PixelDataMemory(data(:,76:100));


            page_op = PageOp_cat_pix();
            page_op  = page_op.init(pix1,pix2,pix3,pix4);

            assertEqual(numel(page_op.npix),4);
            assertEqual(page_op.npix,[25,25,25,25]);

            npix = page_op.npix;
            [npix_chunks, npix_idx,page_op] = page_op.split_into_pages(npix,33);
            assertEqual(numel(npix_chunks),4);
            assertEqual(size(npix_idx),[2,4]);
            assertEqual(npix_idx,[1,2,3,4;2,3,4,4]);
            assertEqual(npix_chunks,{[25,8],[17,16],[9,24],1});

            pb = 1;
            for i=1:4
                page_op = page_op.get_page_data(i,npix_chunks);
                cs = sum(npix_chunks{i});
                pe = pb+cs-1;
                assertEqual(page_op.page_data,data(:,pb:pe));
                pb = pe+1;
            end
        end
        
        function test_get_page_data_4pix_large_even_split_chunks(~)
            n_pix = 100;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,n_pix);
            pix1 = PixelDataMemory(data(:,1:25));
            pix2 = PixelDataMemory(data(:,26:50));
            pix3 = PixelDataMemory(data(:,51:75));
            pix4 = PixelDataMemory(data(:,76:100));


            page_op = PageOp_cat_pix();
            page_op  = page_op.init(pix1,pix2,pix3,pix4);

            assertEqual(numel(page_op.npix),4);
            assertEqual(page_op.npix,[25,25,25,25]);

            npix = page_op.npix;
            [npix_chunks, npix_idx,page_op] = page_op.split_into_pages(npix,50);
            assertEqual(numel(npix_chunks),2);
            assertEqual(size(npix_idx),[2,2]);
            assertEqual(npix_idx,[1,3;2,4]);
            assertEqual(npix_chunks,{[25,25],[25,25]});

            pb = 1;
            for i=1:2
                page_op = page_op.get_page_data(i,npix_chunks);
                cs = sum(npix_chunks{i});
                pe = pb+cs-1;
                assertEqual(page_op.page_data,data(:,pb:pe));
                pb = pe+1;
            end
        end
        %------------------------------------------------------------------
        function test_get_page_data_2pix_smaller_odd_split_chunk(~)
            n_pix = 100;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,n_pix);
            pix1 = PixelDataMemory(data(:,1:50));
            pix2 = PixelDataMemory(data(:,51:100));

            page_op = PageOp_cat_pix();
            page_op  = page_op.init(pix1,pix2);

            assertEqual(numel(page_op.npix),2);
            assertEqual(page_op.npix,[50,50]);


            npix = page_op.npix;
            [npix_chunks, npix_idx,page_op] = page_op.split_into_pages(npix,33);
            assertEqual(numel(npix_chunks),4);
            assertEqual(size(npix_idx),[2,4]);
            assertEqual(npix_idx,[1,1,2,2;1,2,2,2]);
            assertEqual(npix_chunks,{33,[17 16],33,1});

            pb = 1;
            for i=1:4
                page_op = page_op.get_page_data(i,npix_chunks);
                cs = sum(npix_chunks{i});
                pe = pb+cs-1;
                assertEqual(page_op.page_data,data(:,pb:pe));
                pb = pe+1;
            end
        end


        function test_get_page_data_2pix_smaller_even_split_chunk(~)
            n_pix = 100;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,n_pix);
            pix1 = PixelDataMemory(data(:,1:50));
            pix2 = PixelDataMemory(data(:,51:100));

            page_op = PageOp_cat_pix();
            page_op  = page_op.init(pix1,pix2);

            assertEqual(numel(page_op.npix),2);
            assertEqual(page_op.npix,[50,50]);


            npix = page_op.npix;
            [npix_chunks, npix_idx,page_op] = page_op.split_into_pages(npix,25);
            assertEqual(numel(npix_chunks),4);
            assertEqual(size(npix_idx),[2,4]);
            assertEqual(npix_idx,[1,1,2,2;1,1,2,2]);
            assertEqual(npix_chunks,{25,25,25,25});

            for i=1:4
                page_op = page_op.get_page_data(i,npix_chunks);
                pb = (i-1)*25;
                assertEqual(page_op.page_data,data(:,pb+1:pb+25));
            end
        end

        function test_get_page_data_2pix_eq_chunk(~)
            n_pix = 100;
            data = rand(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,n_pix);
            pix1 = PixelDataMemory(data(:,1:50));
            pix2 = PixelDataMemory(data(:,51:100));

            page_op = PageOp_cat_pix();
            page_op  = page_op.init(pix1,pix2);

            assertEqual(numel(page_op.npix),2);
            assertEqual(page_op.npix,[50,50]);


            npix = page_op.npix;
            [npix_chunks, npix_idx,page_op] = page_op.split_into_pages(npix,50);
            assertEqual(numel(npix_chunks),2);
            assertEqual(size(npix_idx),[2,2]);
            assertEqual(npix_idx,[1,2;1,2]);
            assertEqual(npix_chunks,{50,50});

            page_op = page_op.get_page_data(1,npix_chunks);
            assertEqual(page_op.page_data,data(:,1:50));
            page_op = page_op.get_page_data(2,npix_chunks);
            assertEqual(page_op.page_data,data(:,51:100));

        end

        function delete(obj)
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
