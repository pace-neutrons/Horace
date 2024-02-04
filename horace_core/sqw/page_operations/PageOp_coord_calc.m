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
        % PixelDataMemory class, holding current page of data in addition
        % to page_data_ to provide easier access to the PixelData
        % properties
        pix_page;
    end
    properties(Constant)
        xname={'d1';'d2';'d3';'d4'; ...
            'h';'k';'l';'E'; ...
            'Q'};
    end

    methods
        function obj = PageOp_coord_calc(varargin)
            obj = obj@PageOpBase(varargin{:});
            %
            obj.split_at_bin_edges = true;            
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
            obj.pix_page = PixelDataMemory();

            obj.var_acc_ = zeros(numel(obj.npix),1);
        end

        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            obj = get_page_data@PageOpBase(obj,idx,npix_blocks);
            obj.pix_page = obj.pix_page.set_raw_data(obj.page_data_);
        end

        function obj = update_img_accumulators(obj,npix_block,npix_idx, ...
                signal,varargin)
            % OVERLOAD:
            % Recalculate changes in image from changes in
            % pixel data. coord_calc specific code.
            % Inputs:
            % obj        --
            % npix_block -- part of npix array, which containing pixel
            %               distribution within the selected chunk of bins
            % npix_idx   -- indices of the selected cells of image to
            %               modify from pixels
            % s          -- modified pixels signal
            % Returns:
            % obj        -- page_op object containg updated accumulators.


            [s_ar,v_ar,s_msd] = compute_bin_data(npix_block,signal,[],true);
            obj.page_data_(obj.var_idx_,:)  = s_msd;

            obj.sig_acc_(npix_idx(1):npix_idx(2))  = s_ar(:);
            obj.var_acc_(npix_idx(1):npix_idx(2))  = v_ar(:);

        end

        function obj = apply_op(obj,npix_block,npix_idx)
            this_proj = obj.proj;
            type = obj.op_type;
            lind =  obj.ind;
            switch type
                case {'h','k','l'}
                    get_ind = mod(lind-1, 4)+1;
                    uhkl = this_proj.transform_pix_to_hkl(obj.pix_page.q_coordinates);
                    signal = uhkl(get_ind , :);
                case 'E'
                    signal = obj.pix_page.dE+obj.proj.offset(4);
                case 'Q'
                    qq = obj.pix_page.q_coordinates;
                    signal =vecnorm(qq, 2, 1);

                case {'d1', 'd2', 'd3', 'd4'}
                    pax=obj.img_.pax;
                    dax=obj.img_.dax;

                    get_ind = mod(lind-1, 4)+1;
                    get_ind = pax(dax(get_ind));

                    uhkl = this_proj.transform_pix_to_img(obj.pix_page.q_coordinates);
                    signal = uhkl(get_ind , :);
            end
            obj.page_data_(obj.signal_idx_,:)  = signal;
            if obj.changes_pix_only
                return;
            end
            % update image accumulators (overloaded here):
            obj = update_img_accumulators(obj,npix_block,npix_idx,signal);

        end
    end
end