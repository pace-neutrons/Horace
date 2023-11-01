classdef PageOp_binary_sqw_double < PageOp_bin_Base
    % Single page pixel operation used by
    % binary operation manager and applied to two sqw objects and
    % number or array of numbers with size 1, numel(npix) or
    % PixelData.n_pixels
    %
    %
    methods
        function obj = PageOp_binary_sqw_double(varargin)
            obj = obj@PageOp_bin_Base(varargin{:});
        end
        function obj = init(obj,w1,operand,operation,flip,npix,varargin)
            [obj,name_op1] = init@PageOp_bin_Base(obj,w1,operand,operation,flip,npix,varargin{:});

            obj.sigvar2.e   =   [];
            if numel(operand) == 1
                name_op2 = 'scalar';
                obj.scalar_input_ = true;
                obj.sigvar2.s     = operand;
            elseif numel(operand) == numel(obj.npix)
                name_op2 = 'image-size vector';
                obj.scalar_input_ = false;
            else
                error('HORACE:PageOp_binary_sqw_double:invalid_argument', ...
                    ['Number of image pixels (%d) is inconsistent with number of elements (%d)' ...
                    ' of the second operand '], ...
                    numel(obj.npix),obj.pix_.num_pixels,numel(numel(operand)))
            end
            obj = obj.set_op_name(name_op1,name_op2);
        end
        function obj = apply_op(obj,npix_block,npix_idx)
            % perform binary operation between input object and double
            % operand

            % Prepare operands:
            % prepare operands for binary operation
            obj.sigvar1.sig_var    = obj.page_data_(obj.sigvar_idx_,:);
            if ~obj.scalar_input_
                obj.sigvar2.s   =   repelem(obj.operand(npix_idx(1):npix_idx(2)),npix_block);
            end
            % Do operation:
            if obj.flip
                res = obj.op_handle(obj.sigvar2,obj.sigvar1);
            else
                res = obj.op_handle(obj.sigvar1,obj.sigvar2);
            end
            obj.page_data_(obj.sigvar_idx_,:) = res.sig_var;
            if obj.changes_pix_only
                return;
            end
            % update image accumulators:
            obj = update_img_accumulators(obj,npix_block,npix_idx,res.s,res.e);
        end
    end
end