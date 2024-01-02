classdef PageOp_sigvar_set < PageOpBase
    % Single pixel page operation used by sigvar_set and replicate methods
    %
    properties
        % property which should be set to true for replicate
        in_replicate = false;
    end

    methods
        function obj = PageOp_sigvar_set(varargin)
            obj = obj@PageOpBase(varargin{:});
            if obj.in_replicate
                obj.op_name_ = 'sigvar_set';
            else
                obj.op_name_ = 'replicate_with_pix';
            end
            obj.split_at_bin_edges = true;
        end
        function obj = init(obj,sqw_obj)
            % sqw object here already have modified image so we use
            % modified image to set pixels
            obj  = init@PageOpBase(obj,sqw_obj);
            if obj.changes_pix_only
                obj.sig_acc_ = [];
            else
                obj.var_acc_ = zeros(size(obj.sig_acc_));
            end
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            npix = obj.npix(npix_idx(1):npix_idx(2));
            e   = obj.img_.e(npix_idx(1):npix_idx(2));
            s = repelem(obj.img_.s(npix_idx(1):npix_idx(2)),npix  );
            e = repelem(e(:).*npix(:),npix);
            obj.page_data_(obj.signal_idx,:)   = s(:)';
            obj.page_data_(obj.var_idx,:)      = e(:)';
            if obj.changes_pix_only
                return;
            end
            obj = obj.update_img_accumulators(npix_block,npix_idx, ...
                s(:)',e(:)');
        end
    end
    methods(Access=protected)
        function  does = get_changes_pix_only(obj)
            % pageOp calculates pixels only using image as source when
            % sigvar_set is used, but when replicate is deployed, image
            % is recalculated from pixels.
            does = ~obj.in_replicate;
        end
    end
end