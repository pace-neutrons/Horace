classdef PageOp_func_eval < PageOpBase
    % Single pixel page operation used by sqw_eval function
    %
    properties
        % empty operation
        op_holder = @(h,k,l,e){};
        %
    end
    properties(Access = private)
        pix_idx_start_ = 1;
    end

    methods
        function obj = PageOp_func_eval(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'func_eval';
        end
        function [obj,sqw_obj] = init(obj,sqw_obj)
            [obj,sqw_obj] = init@PageOpBase(obj,sqw_obj);
            obj.pix_idx_start_ = 1;
            %
        end
        
        function [npix_chunks, npix_idx] = split_into_pages(~,npix,chunk_size)
            % Method used to split input npix array into pages
            %
            % Overload specific for sqw_eval
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
            [npix_chunks, npix_idx] = split_vector_max_sum(npix, chunk_size);            
        end


        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % Overload specific for sqw_eval. Its average operation needs
            % knolege of all pixel coordinates in a cell.
            npix_block = npix_blocks{idx};
            npix = sum(npix_block(:));
            pix_idx_end = obj.pix_idx_start_+npix-1;
            obj.page_data_ = obj.pix_.get_pixels(obj.pix_idx_start_:pix_idx_end,'-raw');
            obj.pix_idx_start_ = pix_idx_end+1;
        end

        function obj = apply_op(obj,~,npix_idx)
            s = repelem(obj.img_.s(npix_idx(1):npix_idx(2)), obj.npix(npix_idx(1):npix_idx(2)));
            obj.page_data_(obj.signal_idx,:)   = s(:)';
            obj.page_data_(obj.var_idx,:)      = 0;            
        end

        function [out_obj,obj] = finish_op(obj,out_obj)
            % transfer modifications to the underlying object
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
            obj.pix_idx_start_ = 1;
        end

    end
end