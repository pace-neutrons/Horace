classdef PageOp_sigvar_set < PageOpBase
    % Single pixel page operation used by sigvar_set method
    %

    methods
        function obj = PageOp_sigvar_set(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'sigvar_set';
            obj.split_at_bin_edges = true;
        end
        function obj = init(obj,sqw_obj)
            % sqw object here already have modified image so we use
            % modified image to set pixels
            obj  = init@PageOpBase(obj,sqw_obj);
        end

        function obj = apply_op(obj,~,npix_idx)
            npix = obj.npix(npix_idx(1):npix_idx(2));
            s = repelem(obj.img_.s(npix_idx(1):npix_idx(2)),npix  );
            e = repelem(obj.img_.e(npix_idx(1):npix_idx(2)).*npix,npix);
            obj.page_data_(obj.signal_idx,:)   = s(:)';
            obj.page_data_(obj.var_idx,:)      = e(:)';
        end
    end
    methods(Access=protected)
        function  does = get_changes_pix_only(~)
            % pageOp calculates pixels only using image as source. No point
            % of calculating image from pixels again as it would be in
            % usual PageOp
            does = true;
        end
    end
end