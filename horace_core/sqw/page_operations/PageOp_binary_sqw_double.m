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
        function obj = init(obj,w1,operand,operation,flip,varargin)
            % here we definetely expect operand with sigvar_size == [1,1]
            [obj,name_op1] = init@PageOp_bin_Base(obj,w1,operand,operation,flip,varargin{:});
            %
            obj.scalar_input_ = true;
            %
            if isnumeric(obj.operand)
                name_op2 = 'scalar';
                obj.sigvar2.e  =   [];
                obj.sigvar2.s  = operand;
            elseif isa(obj.operand,'sqw') % pixelles sqw with size 1
                name_op2 = '0-dimensional sqw';
                obj.sigvar2 = sigvar(obj.operand.data);
            else
                name_op2 = ['scalar ',class(obj.operand)];
                obj.sigvar2 = sigvar(obj.operand);
            end

            obj = obj.set_op_name(name_op1,name_op2);
        end
        function obj = apply_op(obj,npix_block,npix_idx)
            % perform binary operation between input object and double
            % operand

            % Prepare operands:
            % prepare operands for binary operation
            obj.sigvar1.sig_var    = obj.page_data_(obj.sigvar_idx_,:);
            % Do operation:
            if obj.flip
                res = binary_op_manager_single( ...
                    obj.sigvar2,obj.sigvar1,obj.op_handle);
            else
                res = binary_op_manager_single( ...
                    obj.sigvar1,obj.sigvar2,obj.op_handle);
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