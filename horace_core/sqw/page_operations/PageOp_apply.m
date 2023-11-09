classdef PageOp_apply < PageOp_sqw_eval
    % Single pixel page operation used by apply function
    %
    properties
        % PixelDataMemory class, holding current page of data in addition
        % to page_data_ to provide easier access to the PixelData
        % properties and maintain generic apply function interface
        pix_page      = PixelDataMemory();
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
            % use PageOp_sqw_eval.average== true option to split pixels on
            % ranges of nbins
            obj    = init@PageOp_sqw_eval(obj,in_obj,operation,op_param,true);
            %
            obj.compute_variance = compute_variance;
            obj.changes_pix_only = ~recompute_bins;
            if obj.changes_pix_only
                obj.split_at_bin_edges = false;
            else
                obj.split_at_bin_edges = true;
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
        end

        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % Overload specific for apply. Splits data according to
            % npix ranges and generates PixDataMemory wrapper
            obj = get_page_data@PageOp_sqw_eval(obj,idx,npix_blocks);
            obj.pix_page = obj.pix_page.set_raw_data(obj.page_data_);
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            n_func = numel(obj.op_holder);
            pixpage = obj.pix_page;
            for i = 1:n_func
                pixpage  = obj.op_holder{i}(pixpage, obj.op_parms{i}{:});
            end
            obj.page_data_ = pixpage.data;
            if obj.changes_pix_only
                return;
            end
            new_signal     = pixpage.signal;
            % Overload for 
            if obj.compute_variance
                [img_signal,img_var,sig_variance] = compute_bin_data(npix_block,new_signal,[],true);
                obj.page_data_(obj.var_idx,:)     = sig_variance;
            else
                new_var              = pixpage.variance;
                [img_signal,img_var] = compute_bin_data(npix_block,new_signal,new_var,true);
            end
            obj.sig_acc_(npix_idx(1):npix_idx(2)) = img_signal(:);
            obj.var_acc_(npix_idx(1):npix_idx(2)) = img_var(:);
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