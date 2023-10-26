classdef PageOp_binary_sqw_img < PageOpBase
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
        keep_array;
        flip;
    end
    properties(Access = private)
        pix_idx_start_ = 1;
        % indices of signal and variance fields in pixels
        sigvar_idx_
        % Preallocate two operands, participating in operation
        sigvar1 = sigvar();
        sigvar2 = sigvar();

        npix_idx_;
    end



    methods
        function obj = PageOp_binary_sqw_img(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.sigvar_idx_ = PixelDataBase.field_index('sig_var');
        end

        function obj = init(obj,w1,operand,operation,keep_array,flip,npix)
            obj = init@PageOpBase(obj,w1);

            obj.op_handle = operation;
            obj.operand   = operand;
            obj.keep_array= keep_array;
            obj.flip      = flip;
            if nargin>5
                obj.npix = npix(:);
            end
            if isempty(keep_array)
                obj.keep_array = logical(obj.npix);
            end
            if isempty(obj.img_)
                name1_obj = 'pix';
            else
                name1_obj = 'sqw';
            end
            name2_obj = class(operand);
            obj.op_name_ = ...
                sprintf('binary op: %s between %s and %s', ...
                func2str(operation),name1_obj,name2_obj);
            obj.sigvar2.s   = operand.s(:);
            obj.sigvar2.e   = operand.e(:);
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
            obj.pix_idx_start_ = 1;
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % Method used to split input npix array into pages dividing at
            % the bin edges
            %
            % Overload specific for sqw_img binary operation
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
            [npix_chunks, npix_idx] = split_vector_max_sum(npix, chunk_size);
            obj.npix_idx_ = npix_idx;
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

            obj.pix_idx_start_ = pix_idx_end+1;            
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            % prepare operands for binary operation

            % keep pixels which corresponds to non-empty bins of the second
            % operand
            keep_bins = obj.keep_array(npix_idx(1):npix_idx(2));
            keep_pix  = repelem(keep_bins,npix_block);
            page_data =  obj.page_data_(:,keep_pix);
            obj.sigvar1.sig_var    = page_data(obj.sigvar_idx_,:);

            signal = repelem(obj.operand(imm(1):imm(2)),npix_block);
            obj.sigvar2.s   =   signal;

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

            obj.sig_acc_(npix_idx(1):npix_idx(2))    = s_ar(:);
            obj.var_acc_(npix_idx(1):npix_idx(2))    = e_ar(:);
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_);
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
    end
end