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
            run_id = obj.page_data_(obj.run_idx);

            unique_id = unique(run_id);
            resobj_num  =  arrayfun(@(x)obj.runid_map(x),unique_id);

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