classdef PageOp_binary_sqw_double < PageOpBase
    % Single page pixel operation used by
    % binary operation manager and applied to two sqw objects and
    % number or array of numbers with size 1, numel(npix) or
    % PixelData.n_pixels
    %
    %
    properties
        % property contains handle to function, which performs operation
        op_handle;
        operand;
        flip;
    end
    properties(Access = private)
        pix_idx_start_ = 1;
        % indices of signal and variance fields in pixels
        sigvar_idx_
        % Preallocate two operands, participating in operation
        sigvar1 = sigvar();
        sigvar2 = sigvar();

        img_based_input_ = false;
        pix_based_input_ = false;
        npix_idx_;
    end



    methods
        function obj = PageOp_binary_sqw_double(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.sigvar_idx_ = PixelDataBase.field_index('sig_var');
        end

        function obj = init(obj,w1,operand,operation,flip)
            obj = init@PageOpBase(obj,w1);

            obj.op_handle = operation;
            obj.operand   = operand;
            obj.flip      = flip;

            if isempty(obj.img_)
                name1_obj = 'pix';
            else
                name1_obj = 'sqw';
            end

            if numel(operand) == 1
                obj.op_name_ = ...
                    sprintf('binary op: %s between %s and scalar', ...
                    func2str(operation),name1_obj);
                obj.img_based_input_ = false;
                obj.pix_based_input_ = false;
                obj.sigvar2.s   = operand;
            elseif numel(operand) == numel(obj.npix)
                obj.op_name_ =...
                    sprintf('binary op: %s between %s and image-size vector', ...
                    func2str(operation),name1_obj);
                obj.img_based_input_ = true;
                obj.pix_based_input_ = false;
            elseif numel(operand) == obj.pix_.num_pixels
                obj.op_name_ = ...
                    sprintf('binary op: %s between %s and pixel-size vector', ...
                    func2str(operation),name1_obj);
                obj.img_based_input_ = false;
                obj.pix_based_input_ = true;
            else
                error('HORACE:PageOp_binary_sqw_double:invalid_argument', ...
                    ['Number of image pixels (%d) and total number of pixels' ...
                    ' (%d) are inconsistent with number of elements (%d)' ...
                    ' of the second operand '], ...
                    numel(obj.npix),obj.pix_.num_pixels,numel(numel(operand)))
            end
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
            obj.pix_idx_start_ = 1;
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % Method used to split input npix array into pages dividing at
            % the bin edges
            %
            % Overload specific for sqw_number/vector binary operation
            % Inputs:
            % npix  -- image npix array, which defines the number of pixels
            %          contributing into each image bin and the pixels
            %          ordering in the linear array
            % chunk_size
            %       -- sizes of chunks to split pixels into
            % Returns:
            % npix_chunks -- cellarray, containing the npix parts
            % npix_idx    -- [2,n_chunks] array of indices of the chunks in
            %                the npix array.
            % See split procedure for more details
            if obj.img_based_input_
                [npix_chunks, npix_idx] = split_vector_max_sum(npix, chunk_size);
                obj.npix_idx_ = npix_idx;
            else
                [npix_chunks, npix_idx] = split_vector_fixed_sum(npix, chunk_size);
            end
        end

        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % Overloaded for dealing with two PixelData objects
            npix_block = npix_blocks{idx};
            npix = sum(npix_block(:));
            pix_idx_end = obj.pix_idx_start_+npix-1;

            pix_idx = obj.pix_idx_start_:pix_idx_end;
            obj.page_data_ = obj.pix_.get_pixels(pix_idx,'-raw');

            % prepare operands for binary operation
            obj.sigvar1.sig_var    = obj.page_data_(obj.sigvar_idx_,:);
            if obj.img_based_input_
                imm = obj.npix_idx_(idx);
                signal = repelem(obj.operand(imm(1):imm(2)),npix_block);
                obj.sigvar2.s   =   signal;
            elseif obj.pix_based_input_
                obj.sigvar2.s   =   obj.operand(pix_idx);
            end
            obj.pix_idx_start_ = pix_idx_end+1;
        end


        function obj = apply_op(obj,npix_block,npix_idx)
            % Do operation
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
            [s_ar, e_ar] = compute_bin_data(npix_block,res.s,res.e,true);
            if obj.img_based_input_
                obj.sig_acc_(npix_idx(1):npix_idx(2))    = s_ar(:);
                obj.var_acc_(npix_idx(1):npix_idx(2))    = e_ar(:);
            else
                obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                    obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
                obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                    obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar(:);
            end
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_);
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
    end
end