classdef PageOp_unary_op < PageOpBase
    % Single page pixel operation used by
    % unary operation manager
    %
    %
    properties
        % property contains
        op_handle;
    end

    methods
        function obj = PageOp_unary_op(varargin)
            obj = obj@PageOpBase(varargin{:});

        end

        function [obj,in_obj] = init(obj,in_obj,operation)
            [obj,in_obj] = init@PageOpBase(obj,in_obj);
            obj.op_handle = operation;
            obj.op_name_ = sprintf('unary op: %s',func2str(operation));
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            signal = obj.page_data_(obj.signal_idx_,:);
            var    = obj.page_data_(obj.var_idx_,:);
            pg_result = obj.op_handle(sigvar(signal, var));

            signal = pg_result.s;
            var    = pg_result.e;

            obj.page_data_(obj.signal_idx_,:) = signal;
            obj.page_data_(obj.var_idx_,:)    = var;
            if obj.changes_pix_only
                return;
            end
            % update image accumulators:
            [s_ar, e_ar] = compute_bin_data(npix_block,signal,var,true);

            obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
            obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar(:);
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_);
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
    end
end