classdef PageOp_coord_calc < PageOpBase
    % Single page pixel operation used by
    % signal algorithm
    %
    %
    properties
        % name of the coordinate to transformation from the list
        % below
        op_type;
        % auxiliary index identifing number of the operation in the list of
        % operations
        ind;
        % the projection, which transforms from pixels to image
        proj;
        % PixelDataMemory class, holding current page of data
        pixpage;
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
            obj.op_name_ = sprintf('set signal to %s',obj.op_type);
            obj.pixpage = PixelDataMemory();
        end
        function obj = get_page_data(obj,idx,varargin)
            % return block of data used in page operation
            %
            % This is most common form of the operation. Some operations
            % will request overloading
            obj.pix_.page_num = idx;
            obj.page_data_ = obj.pix_.data;
            obj.pixpage = obj.pixpage.set_raw_data(obj.page_data_);
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            this_proj = obj.proj;
            type = obj.op_type;
            lind =  obj.ind;
            switch type
                case {'h','k','l'}
                    get_ind = mod(lind-1, 4)+1;
                    uhkl = this_proj.transform_pix_to_hkl(obj.pagepix.q_coordinates);
                    signal = uhkl(get_ind , :);
                case 'E'
                    signal = obj.pixpage.dE+obj.proj.offset(4);
                case 'Q'
                    qq = obj.pagepix.q_coordinates;
                    signal =vecnorm(qq, 2, 1);

                case {'d1', 'd2', 'd3', 'd4'}
                    pax=obj.img_.pax;
                    dax=obj.img_.dax;

                    get_ind = mod(lind-1, 4)+1;
                    get_ind = pax(dax(get_ind));

                    uhkl = this_proj.transform_pix_to_img(obj.pagepix.q_coordinates);
                    signal = uhkl(get_ind , :);
            end
            obj.page_data(obj.signal_idx_,:)  = signal;
            if obj.changes_pix_only
                return;
            end
            % update image accumulators:
            [s_ar,v_ar,s_msd] = compute_bin_data(npix_block,signal,[],true);
            obj.page_data(obj.var_idx_,:)  = s_msd;


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