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
        flip   % if true, actual operation is between w2 and w1 instead of
        % input order, because the result has the size and shape of
        % the larger object, but actual request was
    end
    properties(Access = private)
        pix_idx_start_ = 1;
        % indices of signal and variance fields in pixels
        sigvar_idx_
        % Preallocate two operands, participating in operation
        sigvar1 = sigvar();
        sigvar2 = sigvar();

        scalar_input_ = true;
    end

    methods
        function obj = PageOp_binary_sqw_double(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.sigvar_idx_ = PixelDataBase.field_index('sig_var');
        end
        function obj = init(obj,w1,operand,operation,flip,npix)
            obj = init@PageOpBase(obj,w1);

            obj.op_handle = operation;
            obj.operand   = operand;
            obj.flip      = flip;

            if isempty(obj.img_)
                name1_obj = 'pix'; % this is for pix-pix operations
            else
                name1_obj = 'sqw';
            end
            if nargin>5 && ~isempty(npix)
                if obj.pix_.num_pixels ~= sum(npix(:))
                    error('HORACE:PageOp_binary_sqw_double:invalid_argument', ...
                        ['Number of pixels of the first operand (%d) inconsistent ' ...
                        'with its distribution, provided as #5th argument npix (%d)'], ...
                        obj.pix_.num_pixels,sum(npix(:)));
                end
                obj.npix = npix(:);
            end
            obj.sigvar2.e   =   [];
            if numel(operand) == 1
                if flip
                    name2_obj = name1_obj;
                    name1_obj = 'scalar';
                else
                    name2_obj = 'scalar';
                end
                obj.scalar_input_ = true;
                obj.sigvar2.s     = operand;
            elseif numel(operand) == numel(obj.npix)
                if flip
                    name2_obj = name1_obj;
                    name1_obj = 'image-size vector';
                else
                    name2_obj = 'image-size vector';
                end
                obj.scalar_input_ = false;
            else
                error('HORACE:PageOp_binary_sqw_double:invalid_argument', ...
                    ['Number of image pixels (%d) is inconsistent with number of elements (%d)' ...
                    ' of the second operand '], ...
                    numel(obj.npix),obj.pix_.num_pixels,numel(numel(operand)))
            end
            obj.op_name_ = ...
                sprintf('binary op: %s between %s and %s', ...
                func2str(operation),name1_obj,name2_obj);

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
            if obj.scalar_input_
                [npix_chunks, npix_idx] = split_vector_fixed_sum(npix, chunk_size);
            else
                [npix_chunks, npix_idx] = split_vector_max_sum(npix, chunk_size);
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

            obj.pix_idx_start_ = pix_idx_end+1;
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
            [s_ar, e_ar] = compute_bin_data(npix_block,res.s,res.e,true);
            if obj.scalar_input_
                obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                    obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
                obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                    obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar(:);
            else
                obj.sig_acc_(npix_idx(1):npix_idx(2))    = s_ar(:);
                obj.var_acc_(npix_idx(1):npix_idx(2))    = e_ar(:);
            end
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_);
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
    end
end