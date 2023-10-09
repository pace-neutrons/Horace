classdef PageOp_recompute_bins < PageOpBase
    % Single pixels page operation which does not change the pixels values
    %
    % Used by recompute_bin_data method or recalc_data_range method
    %
    methods
        function obj = PageOp_recompute_bins(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'recompute_bin_data_and_ranges';
        end

        function [obj,in_obj] = init(obj,in_obj)
            [obj,in_obj] = init@PageOpBase(obj,in_obj);
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
        end
        function obj = apply_op(obj,npix_block,npix_idx)
            if isempty(obj.img_)
                return;
            end
            % retrieve signal and error
            signal = obj.page_data_(obj.signal_idx,:);
            error  = obj.page_data_(obj.var_idx,:);
            % update image accumulators:
            [s_ar, e_ar] = compute_bin_data(npix_block,signal,error,true);
            obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
            obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar(:);
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            % Complete image modifications:
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_);

            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
    end
end