classdef test_PageOp_sqw_binning < TestCaseWithSave
    properties
        test_dir;
        work_dir;
        sample_obj;
        sqw_to_join;
        files_to_join;
    end

    methods
        function obj = test_PageOp_sqw_binning(varargin)
            if nargin == 0
                opt = 'test_PageOp_sqw_binning';
            else
                opt = varargin{1}; % may be save
            end
            this_folder = fileparts(mfilename("fullpath"));
            obj = obj@TestCaseWithSave(opt,fullfile(this_folder,'test_PageOp_sqw_binning.mat'));

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
                fn = sprintf('%s_runID%d',fn,id(1));
                fn = fullfile(obj.work_dir,fn);
                obj.files_to_join{i} = fn;
                if isfile(fn)
                    continue;
                end
                save(obj.sqw_to_join(i),fn);
            end
            obj.save();
        end
        function delete(obj)
            if ~isempty(obj.work_dir) && isfolder(obj.work_dir)
                rmdir(obj.work_dir,'s');
            end
        end
        %------------------------------------------------------------------
        function test_op_on_objects_equal_to_combine_in_memory_with_par(obj)
            proj = obj.sample_obj.data.proj;
            bins = obj.sample_obj.data.axes.get_cut_range('-full_range');

            mobj = sqw_op_bin_pixels(obj.sqw_to_join, ...
                @(x,varargin)null_op_(obj,x,varargin{:}),[], ...
                proj,bins{:},...
                '-combine');
            if obj.save_output
                return;
            end
            sample = obj.getReferenceDataset( ...
                'test_op_on_objects_equal_to_combine_in_memory_without_par','mobj');

            assertEqualToTol(mobj,sample,[1.e-7,1.e-7], ...
                '-ignore_str','-ignore_date');
        end

        function test_op_on_objects_equal_to_combine_on_file_without_par(obj)
            clWa = set_temporary_warning('off','HOR_CONFIG:set_mem_chunk_size');
            clOb = set_temporary_config_options(hor_config, ...
                'mem_chunk_size',200,'fb_scale_factor',3);
            mobj = sqw_op_bin_pixels(obj.files_to_join, ...
                @(x,varargin)null_op_(obj,x,varargin{:}),[],'-combine');

            if obj.save_output
                return;
            end
            sample = obj.getReferenceDataset( ...
                'test_op_on_objects_equal_to_combine_in_memory_without_par','mobj');
            assertEqualToTol(mobj,sample ,[1.e-7,1.e-7],'-ignore_str','-ignore_date');
        end

        function test_op_on_objects_equal_to_combine_in_memory_without_par(obj)
            mobj = sqw_op_bin_pixels(obj.sqw_to_join, ...
                @(x,varargin)null_op_(obj,x,varargin{:}),[],'-combine');

            assertEqualToTolWithSave(obj,mobj,[1.e-7,1.e-7], ...
                '-ignore_str','-ignore_date');
        end

        function test_split_multipix_data_get_multipix_pages(obj)
            chunk_size = 9000;
            [tds,npix,pix_data,chunks]= obj.get_test_multipix_ds(4,10,chunk_size);
            pop_obj = PageOp_sqw_binning();
            pop_obj = pop_obj.init(tds,@(x,varargin)null_op_(obj,x,varargin{:}),[], ...
                tds.data.axes,tds.data.proj, ...
                struct('combine',true,'nopix',false));

            [npix_chunks, npix_idx,pop_obj] = pop_obj.split_into_pages(tds.data.npix,chunk_size);

            assertEqual(sum([npix_chunks{:}]),sum(npix));
            assertEqual(size(npix_idx,2),numel(chunks));
            for i=1:4
                this_ds = npix_idx(1,:) == i;
                these_chunks = [npix_chunks{this_ds}];
                ref_chinks = chunks(this_ds);
                assertVectorsAlmostEqual(these_chunks,ref_chinks);
            end
            % now let's check pix pages
            all_idx = npix_idx(1,:);
            ds_num = all_idx(1);
            num_pixels = pix_data{ds_num}.num_pixels;
            pix_idx0 = 0;
            for i= 1:numel(npix_chunks)
                pop_obj = pop_obj.get_page_data(i,npix_chunks);
                %
                if ds_num ~= all_idx(i)
                    ds_num = all_idx(i);
                    num_pixels = pix_data{ds_num}.num_pixels;
                    pix_idx0 = 0;
                end
                block_size = min(chunk_size,num_pixels-pix_idx0);
                pix_idx1 = pix_idx0+block_size;

                assertEqual(pop_obj.page_data, ...
                    pix_data{ds_num}.get_pixels( ...
                    pix_idx0+1:pix_idx1,'-raw','-align'));
                pix_idx0 = pix_idx1;
            end
        end
    end
    methods(Access=private)
        function data = null_op_(~,pop,varargin)
            % define no paging operation, which works and returns pixels
            % unchanged.
            data = pop.page_data;
        end
        function [multipix_ds,npix,pix_list,chunks] = get_test_multipix_ds(~,n_datasets,n_pixels,ChunkSize)
            % get test dataset to check PageOp_sqw_binning initialization and
            % specific class methods.
            all_ds= cell(1,n_datasets);
            var = rand(1,n_datasets);
            npix_list = cell(1,n_datasets);
            pix_list = cell(1,n_datasets);
            chunks   = cell(1,n_datasets);
            for i = 1:n_datasets
                n_pix = floor(n_pixels*(1+var(i)));

                all_ds{i} = sqw.generate_cube_sqw(n_pix);
                all_ds{i}.data.do_check_combo_arg = false;
                all_ds{i}.data.axes.img_range= [-1,-2,-3,-5;1,2,3,10];
                all_ds{i}.data.npix = all_ds{i}.pix.num_pixels;
                all_ds{i}.data.s    = 1;
                all_ds{i}.data.e    = 1;
                pix_list{i}  = all_ds{i}.pix;
                npix_list{i} = pix_list{i}.num_pixels;
                nl_chunks = floor(npix_list{i}/ChunkSize);
                if nl_chunks*ChunkSize<npix_list{i}
                    nl_chunks = nl_chunks+1;
                    chunks{i} = ones(1,nl_chunks)*ChunkSize;
                    chunks{i}(end) = npix_list{i}-(nl_chunks-1)*ChunkSize;
                else
                    chunks{i} = ones(1,nl_chunks)*ChunkSize;
                end

            end
            chunks = [chunks{:}];
            pix_cobj = pixobj_combine_info(pix_list,npix_list);
            multipix_ds = all_ds{1};
            npix = [npix_list{:}];
            multipix_ds.data.npix = npix;
            multipix_ds.data.s    = ones(1,n_datasets);
            multipix_ds.data.e    = ones(1,n_datasets);
            multipix_ds.pix = pix_cobj;
        end
    end
end
