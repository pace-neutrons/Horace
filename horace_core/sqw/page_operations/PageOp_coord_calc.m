classdef PageOp_coord_calc < PageOpBase
    % Single page pixel operation used by
    % signal algorithm
    %
    %
    properties
        % name of the coordinate to transformation from the list
        % below
        op_type;
        % auxiliary index identifying number of the operation in the list of
        % operations
        ind;
        % the projection, which transforms from pixels to image
        proj;
        % PixelDataMemory class, holding current page of data
        pixpage;
    end
    properties(Access = private)
        pix_idx_start_ = 1;
    end
    
    properties(Constant)
        xname={'d1';'d2';'d3';'d4'; ...
            'h';'k';'l';'E'; ...
            'Q'};
    end

    methods
        function obj = PageOp_coord_calc(varargin)
            obj = obj@PageOpBase(varargin{:});
        end

        function obj = init(obj,in_obj,ind)
            obj = init@PageOpBase(obj,in_obj);
            if obj.changes_pix_only
                error('HORACE:PageOp_coord_calc:invalid_argument', ...
                    'This method requests full sqw object as input but only pixels were provided')
            end
            obj.ind = ind;
            obj.op_type = obj.xname{ind};
            obj.op_name_ = sprintf('"set signal to %s"',obj.op_type);
            obj.proj = obj.img_.proj;
            obj.pixpage = PixelDataMemory();

            obj.var_acc_ = zeros(numel(obj.npix),1);
                    obj.pix_idx_start_ = 1;
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % Method used to split input npix array into pages
            %
            % Overload specific for coord_calc
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
            npix_block = npix_blocks{idx};
            npix = sum(npix_block(:));
            pix_idx_end = obj.pix_idx_start_+npix-1;
            obj.page_data_ = obj.pix_.get_pixels( ...
                obj.pix_idx_start_:pix_idx_end,'-raw');
            obj.pix_idx_start_ = pix_idx_end+1;
            %
            obj.pixpage = obj.pixpage.set_raw_data(obj.page_data_);
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            this_proj = obj.proj;
            type = obj.op_type;
            lind =  obj.ind;
            switch type
                case {'h','k','l'}
                    get_ind = mod(lind-1, 4)+1;
                    uhkl = this_proj.transform_pix_to_hkl(obj.pixpage.q_coordinates);
                    signal = uhkl(get_ind , :);
                case 'E'
                    signal = obj.pixpage.dE+obj.proj.offset(4);
                case 'Q'
                    qq = obj.pixpage.q_coordinates;
                    signal =vecnorm(qq, 2, 1);

                case {'d1', 'd2', 'd3', 'd4'}
                    pax=obj.img_.pax;
                    dax=obj.img_.dax;

                    get_ind = mod(lind-1, 4)+1;
                    get_ind = pax(dax(get_ind));

                    uhkl = this_proj.transform_pix_to_img(obj.pixpage.q_coordinates);
                    signal = uhkl(get_ind , :);
            end
            obj.page_data_(obj.signal_idx_,:)  = signal;
            if obj.changes_pix_only
                return;
            end
            % update image accumulators:
            [s_ar,v_ar,s_msd] = compute_bin_data(npix_block,signal,[],true);
            obj.page_data_(obj.var_idx_,:)  = s_msd;


            obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
            obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.var_acc_(npix_idx(1):npix_idx(2)) + v_ar(:);

        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_);
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
    end
end