classdef PageOp_split_sqw < PageOpBase
    % Single page pixel operation and main gateway for
    % sqw.split  algorithm.
    %
    %
    properties
        % cellarrsy of the resulting sqw objects to be split into
        out_sqw;
        runid_map;
    end
    properties(Access = private)
        page_size_;
        % the position of pixels in every pixel block
        pix_block_start_;
        % indixes of pages in the npix array, produced by split_into_pages
        block_idx_
    end
    methods
        function obj = PageOp_split_sqw(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'split_sqw';
            obj.split_at_bin_edges = false;
        end

        function obj = init(obj,in_sqw,runid_map,varargin)
            obj = init@PageOpBase(obj,in_sqw);
            obj.runid_map = runid_map;


        end

        function obj = apply_op(obj,npix_block,npix_idx)
            run_id = obj.page_data_(obj.run_idx,:);

            unique_id = unique(run_id);

            ibin  = repelem(1:nbins, npix_block(:))';

            for n_obj = 1:numel(unique_id) %
                this_id    = unique_id(n_obj);
                resobj_num = obj.runid_map(this_id);
                % extract data belonging to single sqw
                this_img   = obj.out_sqw{resobj_num}.data;
                this_pix   = run_id == this_id;
                obj_pix    = obj.page_data_(:,this_pix);
                obj_bins   = ibin(this_pix);
                obj_npix   = accumarray(obj_bins, ones(1, sum(obj_bins)), [nbins, 1]);
                [s_ar, e_ar] = compute_bin_data( ...
                    obj_npix,obj_pix(obj.signal_idx,:),obj_pix(obj.var_idx,:),true);
                this_img.s(npix_idx(1):npix_idx(2))    = ...
                    this_img.s(npix_idx(1):npix_idx(2)) + s_ar(:);
                this_img.e(npix_idx(1):npix_idx(2))    = ...
                    this_img.e(npix_idx(1):npix_idx(2)) + e_ar(:);
                this_img.npix(npix_idx(1):npix_idx(2))    = ...
                    this_img.npix(npix_idx(1):npix_idx(2)) + obj_npix(:);
                % assign modified data back to sqw obj
                obj.out_sqw{resobj_num}.data = this_img;
                obj.out_sqw.pix = obj.out_sqw.pix.set_raw_data(obj_pix);
            end
        end

        function obj = common_page_op(obj)
            % Method contains split_sqw-specific code which runs for any
            % page operation.
            %
            % Input:
            % obj   -- pageOp object, containing modified pixel_data page
            %          to analyse.
            %
            obj.pix_data_range_ = PixelData.pix_minmax_ranges(obj.page_data_, ...
                obj.pix_data_range_);
            if obj.exp_modified
                obj.unique_run_id_ = unique([obj.unique_run_id_, ...
                    obj.page_data_(obj.run_idx_,:)]);
            end
            if ~obj.inplace_
                obj.pix_ = obj.pix_.store_page_data(obj.page_data_,obj.write_handle_);
            end
        end

        %
    end
end