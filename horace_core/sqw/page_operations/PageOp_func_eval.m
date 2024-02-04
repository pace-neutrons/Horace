classdef PageOp_func_eval < PageOpBase
    % Single pixel page operation used by sqw_eval function
    %

    methods
        function obj = PageOp_func_eval(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'func_eval';
            obj.split_at_bin_edges = true;
        end
        function obj = init(obj,sqw_obj)
            obj  = init@PageOpBase(obj,sqw_obj);
            %
            obj.img_.e =zeros(size(obj.img_.s)) ; % image in funceval have
            % been calculated separately. PageOp calculates pixels only.
        end

        function obj = apply_op(obj,~,npix_idx)
            s = repelem(obj.img_.s(npix_idx(1):npix_idx(2)), obj.npix(npix_idx(1):npix_idx(2)));
            obj.page_data_(obj.signal_idx,:)   = s(:)';
            obj.page_data_(obj.var_idx,:)      = 0;
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