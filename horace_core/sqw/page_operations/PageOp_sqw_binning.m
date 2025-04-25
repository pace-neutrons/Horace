classdef PageOp_sqw_binning < PageOp_sqw_eval
    % Single pixel page operation used by sqw_op_bin_pixels algorithm
    %
    properties(Access=protected)
        % accumulator for number of pixels contributing to each cell.
        % unlike other PageOp, this operation changes this number so source
        % npix arry is not appropriate for this purpose and additional
        % accumulator is requested.
        npix_acc_;
        % storage for PixelDataMemory class used as target for page of
        % pixel data. Allocated to avoid reallcating it in each page
        % operation.
        pix_page_;
        % properly contains information about pre-processed pixels
        % cache used to write bunch of data to file or store in memory
        % if it is still possible.
        pix_combine_info_;
        % holder for target access property
        targ_axes_;
        % maximal size of pixel array to keep in memory until it should
        % be stored in file
        buf_size_;
    end

    methods
        function obj = PageOp_sqw_binning(varargin)
            obj = obj@PageOp_sqw_eval(varargin{:});
            obj.op_name_ = 'sqw_op_bin_pixels';
        end
        function obj = init(obj,sqw_obj,operation,op_param, ...
                targ_ax_block,targ_proj,pop_options)
            % Initialize PageOp_sqw_op operation over input sqw file
            %
            % Inputs:
            % obj       -- instance of PageOp_sqw_op class
            % sqw_obj   -- intance of sqw object to perform operation on
            % operation -- function handle to the function constructed according
            %              to sqw_op function rules, which would perform
            %              the operation
            % op_param  -- cellarray of operation parameters to be provided
            %              to operation in the form:
            %              operation(obj,op_param{:});
            % targ_ax_block
            %           -- Properly initialized axes block used as part of
            %              target image obtained from binned pixels.
            % targ_proj -- Properly initialized projection, part of target
            %              image used for transforming modified pixels into image
            %              coordinate system defined by input projection
            %              and input target block
            %
            % Returns:
            % obj      --  PageOp_sqw_op instance initialized to run
            %              operation over it
            %
            obj = init@PageOp_sqw_eval(obj,sqw_obj,operation,op_param,false);
            obj.do_nopix = pop_options.nopix;
            %
            if pop_options.nopix && obj.init_filebacked_output
                % This is because sqw_eval does not support filebacked
                % output. Until it does not support it, here we should deal
                % with it
                obj.init_filebacked_output = false;
                if ~isempty(obj.write_handle_)
                    obj.write_handle_.delete();
                    obj.write_handle_ = [];
                end
            end

            %local target access block holder
            obj.targ_axes_ = targ_ax_block;
            % and projection, which responsible for building target image
            obj.proj       = targ_proj;
            % define new target image
            obj.img_  = DnDBase.dnd(targ_ax_block,targ_proj);

            % clear image's npix,s,e array to save memory. They will
            % be set up from the accumulators at the end of calculations
            % TODO: possibility of optimization. Not to allocate them from
            % the start
            obj.img_.do_check_combo_arg = false;
            obj.img_.npix = [];
            obj.img_.s = [];
            obj.img_.e = [];

            obj.split_at_bin_edges = true;

            [obj.npix_acc_,obj.sig_acc_,obj.var_acc_] = targ_ax_block.init_accumulators(3,false);
            %
            obj.pix_page_ = PixelDataMemory();
            [chunk_size,fb_size] = config_store.instance().get_value( ...
                'hor_config','mem_chunk_size','fb_scale_factor');
            obj.buf_size_ = chunk_size*fb_size;
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % Method used to split input npix array into pages
            % Inputs:
            % npix  -- image npix array, which defines the number of pixels
            %           contributing into each image bin and the pixels
            %           ordering in the linear array
            % chunk_size
            %       -- sized of chunks to split pixels
            % Returns:
            % npix_chunks -- cellarray, containing the npix parts
            % npix_idx    -- [2,n_chunks] array of indices of the chunks in
            %                the npix array.
            % See split procedure for more details
            [npix_chunks, npix_idx,obj] = split_into_pages@PageOpBase(obj,npix,chunk_size);
            if obj.do_nopix_ || ~obj.init_filebacked_output_
                return;
            end
            % we create new target file with correct ranges. No range
            % warning is needed.
            obj.issue_range_warning = false;
            % clear internal accumulators for cut_data_from_file_job job,
            % used to accumulate pixels.
            cut_data_from_file_job.accumulate_pix('cleanup');

            % intialize pix_combine_info to store pixel data if one wants to
            % store modified pixels
            wk_dir = get(parallel_config, 'working_directory');
            n_files = numel(npix_chunks);
            tmp_file_names = gen_unique_file_paths(n_files, 'horace_cut', wk_dir);

            nbins = numel(obj.npix_acc_);
            obj.pix_combine_info_ = pixfile_combine_info(tmp_file_names, nbins);
            % disable standard filebacked output used by PageOp,
            % as it will be performed by cut write algorithm, used by cut.
            if isempty(obj.outfile)
                obj.outfile_ = obj.write_handle_.write_file_name;
            end
            % this will delete existing tmp file if any is there
            obj.write_handle_.delete();
            obj.write_handle_ = [];


        end
        function obj = common_page_op(obj)
            % Overloaded code which runs for every page_op_bin_pixels
            % operation.
            %
            % Input:
            % obj   -- pageOp object, containing modified pixel_data page
            %          to analyse.
            %
            % Returns:
            % obj   -- modified PageOp class, containing:
            %      a)  updated pix_data_range_ field, containing pixel data
            %          range (min/max values ) calculated accounting for
            %          recent page data
            %
            % Unlike parent operation this one does not store page data,
            % as page data storage works differently with binning and,
            % if necessary, perforemed in apply_op
            obj.pix_data_range_ = PixelData.pix_minmax_ranges(obj.page_data_, ...
                obj.pix_data_range_);
            % criteria for saving result here are different. Only
            % memory-based output should be stored in pix_, as filebacked would be
            % put in cashe to be combined later.
            if ~(obj.init_filebacked_output_ || obj.do_nopix_)
                obj.pix_ = obj.pix_.store_page_data(obj.page_data_,obj.write_handle_);
            end

        end

        function obj = apply_op(obj,varargin)
            % Apply user-defined operation over page of pixels located in
            % memory. Pixels have to be split on bin edges
            %
            % Inputs:
            % obj         -- initialized instance of PageOp_sqw_eval class
            % npix_block  -- array containing distrubution of pixel loaded into current page
            %                over image bins of the processed data chunk
            % npix_idx    -- 2-element array [nbin_min,nbun_max] containing
            %                min/max indices of the image bins
            %                corresponding to the pixels, currently loaded
            %                into page.
            % Returns:
            % obj         -- modified object with pixels page currently in
            %                memory being modified by user operation and
            %                image accumulators (signal and variane for
            %                image being updated with modifies pixels
            %                signal and error.
            %
            % NOTE:
            % pixel data are split over bin edges (see split_vector_max_sum
            % for details), so npix_idx contains min/max indices of
            % currently processed image cells.
            page_data = obj.op_holder(obj, obj.op_parms{:});
            obj.page_data_ = page_data;
            if isempty(page_data)
                return;
            end
            % retrieve pixelDataMemory class cached in property for
            % performance and not to run constructor at each page call.
            pix = obj.pix_page_;
            pix = pix.set_raw_data(page_data);

            if obj.do_nopix_
                [obj.npix_acc_,obj.sig_acc_,obj.var_acc_] = obj.proj.bin_pixels(...
                    obj.img_.axes,pix, ...
                    obj.npix_acc_,obj.sig_acc_,obj.var_acc_);
            else
                [obj.npix_acc_,obj.sig_acc_,obj.var_acc_, pix_ok,...
                    unique_runid_l, pix_indx] = ...
                    obj.proj.bin_pixels(obj.targ_axes_, pix, ...
                    obj.npix_acc_,obj.sig_acc_,obj.var_acc_);
                % pix_ok have probably lost some pixels after rebinning
                obj.page_data_ = pix_ok.data;
                if obj.exp_modified
                    obj.unique_run_id_ = unique([obj.unique_run_id_, ...
                        unique_runid_l(:)']);
                end
                if obj.init_filebacked_output_ && ~obj.do_nopix_
                    % Store produced data in cache, and when the cache is full
                    % generate tmp files. Return pixfile_combine_info object to manage
                    % the files - this object then used to recombine the files within
                    % PageOp_sqw_join operation.
                    obj.pix_combine_info_ = cut_data_from_file_job.accumulate_pix( ...
                        obj.pix_combine_info_, false, ...
                        pix_ok, pix_indx, obj.npix_acc_, ...
                        obj.buf_size_);
                end
            end
        end
        %
        %
        function [out_obj,obj] = finish_op(obj,out_obj)
            % Overloaded to do operations, specific to pixels binning
            % The coude roughly repeats the one deployed by cut_sqw
            %
            % transfer image modifications to the underlying object.
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_,obj.npix_acc_);
            if ~isempty(obj.pix_combine_info_)
                % finalize pixel combining procedure; write all pixels
                % still in memory into appropriate tmp files. set up output
                % object pixels into pix_combine_info object, which have
                % information about object combining
                obj.pix_ = cut_data_from_file_job.accumulate_pix( ...
                    obj.pix_combine_info_, true,[],[],obj.npix_acc_);
                combine_pixels = true;
            else
                combine_pixels = false;
            end
            % if filebacked, this will create sqw object with
            % combine_pixel_data object in sqw_obj.pix_ field
            [out_obj,obj] = obj.finish_core_op(out_obj);
            %
            if ~combine_pixels
                return
            end
            %ask configuration on selected way of combining pixels together.
            hpc = hpc_config;
            hc = hor_config;
            use_mex = hc.use_mex && strcmp(hpc.combine_sqw_using,'mex_code');
            %
            % combine partial pixel data together to obtain fully fledged
            % filebacked sqw object.
            page_op         = PageOp_join_sqw;
            page_op.outfile = obj.outfile;
            [page_op,out_obj] = page_op.init(out_obj,[],use_mex);
            out_obj           = sqw.apply_op(out_obj,page_op);
            cut_data_from_file_job.accumulate_pix('cleanup');
        end
        %------------------------------------------------------------------
    end
    methods(Access=protected)
        function  do = get_exp_modified(~)
            % bining would likely remove some pixels so we need to check
            % consistence between pixels and experiment data
            do = true;
        end
    end
end
