classdef PageOp_apply < PageOp_sqw_eval
    % Single pixel page operation used by apply function
    %
    properties
        page_pix      = PixelDataMemory();
        %
        compute_variance = false;
        change_pix_only_ = false;
    end
    methods
        function obj = PageOp_apply(varargin)
            obj = obj@PageOp_sqw_eval(varargin{:});
            obj.op_name_ = 'generic_apply';
        end
        function obj = init(obj,in_obj,operation,op_param,compute_variance,recompute_bins)
            if ~iscell(op_param)
                op_param= {{op_param}};
            end
            if isa(operation, 'function_handle')
                operation = {operation};
            end
            if numel(op_param) == 1
                op_param = repmat(op_param, numel(operation), 1);
            elseif numel(op_param) ~= numel(operation)
                error('HORACE:PageOp_apply:invalid_argument', ...
                    'Number of arguments does not match number of function handles')
            end
            obj    = init@PageOp_sqw_eval(obj,in_obj,operation,op_param,true);
            %
            obj.compute_variance = compute_variance;
            obj.changes_pix_only = ~recompute_bins;
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
        end

        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % Overload specific for apply. Its average operation needs
            % knolege of all pixel coordinates in a cell.
            obj = get_page_data@PageOp_sqw_eval(obj,idx,npix_blocks);
            obj.page_pix = obj.page_pix.set_raw_data(obj.page_data_);
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            n_func = numel(obj.op_holder);
            page_pxls = obj.page_pix;
            for i = 1:n_func
                page_pxls  = obj.op_holder{i}(page_pxls, obj.op_parms{i}{:});
            end
            obj.page_data_ = page_pxls.data;
            new_signal     = page_pxls.signal;
            new_var        = page_pxls.variance;
            if obj.changes_pix_only
                return;
            end
            %
            if obj.compute_variance
                [img_signal,img_var,sig_variance] = compute_bin_data(npix_block,new_signal,[],true);
                obj.page_data_(obj.var_idx,:)     = sig_variance;
            else
                [img_signal,img_var] = compute_bin_data(npix_block,new_signal,new_var,true);
            end
            obj.sig_acc_(npix_idx(1):npix_idx(2)) = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2))+img_signal(:);
            obj.var_acc_(npix_idx(1):npix_idx(2)) = ...
                obj.var_acc_(npix_idx(1):npix_idx(2))+img_var(:);

        end

        function [out_obj,obj] = finish_op(obj,out_obj)
            if ~obj.changes_pix_only
                % Complete image modifications:
                obj = obj.update_image(obj.sig_acc_,obj.var_acc_);
            end

            % transfer modifications to the underlying object
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end
    end
    methods(Access=protected)
        function  does = get_changes_pix_only(obj)
            does = isempty(obj.img_)|| obj.change_pix_only_;
        end
        function obj = set_changes_pix_only(obj,val)
            obj.change_pix_only_ = logical(val);
        end
    end
end