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

        function obj = init(obj,in_obj,operation)
            obj = init@PageOpBase(obj,in_obj);
            obj.op_handle = operation;
            obj.op_name_ = sprintf('unary op: %s',func2str(operation));
            if obj.changes_pix_only
                obj.split_at_bin_edges = false;
            else
                obj.split_at_bin_edges = true;
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
            obj = obj.update_img_accumulators(npix_block,npix_idx, ...
                signal,var);
        end
    end
end