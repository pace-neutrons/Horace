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
        flip;
        %
        keep_array;
    end
    properties(Access = private)
        pix_idx_start_ = 1;
        % indices of signal and variance fields in pixels
        sigvar_idx_
        % Preallocate two operands, participating in operation
        sigvar1 = sigvar();
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
            if nargin>5 && ~isempty(npix)
                %  This is for operations with pixels only, when you may want
                %  it. Normally, npix comes from w1
                obj.npix = npix(:);
                npix_provided = true;
            else
                npix_provided = false;                
            end
            if isempty(keep_array)
                obj.keep_array = logical(obj.npix(:));
            else
                obj.keep_array = keep_array;
            end
            if isempty(obj.img_)
                name1_obj = 'pix';
            else
                name1_obj = 'sqw';
            end
            if flip
                name2_obj = name1_obj;
                name1_obj = class(operand);
            else
                name2_obj = class(operand);
            end
            obj.op_name_ = ...
                sprintf('binary op: %s between %s and %s', ...
                func2str(operation),name1_obj,name2_obj);
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end

            is_dnd_base = isprop(obj.operand,'npix');
            if numel(obj.npix)== 1 && is_dnd_base && ~npix_provided 
                % pix <-> DnDBase operation. Needs to be done in npix steps
                obj.npix = obj.operand.npix(:);
            end

            % Are operation members consistent?
            nobj1_elements = obj.pix_.num_pixels;
            if is_dnd_base
                nobj2_elements = sum(obj.operand.npix(:));
            else
                nobj2_elements = sum(obj.npix(:));
            end
            if nobj1_elements ~= nobj2_elements
                error('HORACE:PageOp_binary_sqw_img:invalid_argument', ...
                    '%s attempted between inconsistent objects. %s has %d pixels and obj %s addresses %d pixels', ...
                    obj.op_name_,name1_obj,nobj1_elements,name2_obj,nobj2_elements);
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
        end

        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % Overloaded for dealing with two PixelData objects
            npix_block = npix_blocks{idx};
            npix = sum(npix_block(:));
            pix_idx_end = obj.pix_idx_start_+npix-1;

            obj.page_data_ = obj.pix_.get_pixels(obj.pix_idx_start_:pix_idx_end,'-raw');

            obj.pix_idx_start_ = pix_idx_end+1;
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            % perform binary operation between input object and image-like
            % operand

            % keep pixels which corresponds to non-empty bins of the second
            % operand. This is the code from mask operation
            img_block_idx = npix_idx(1):npix_idx(2);
            keep_page_bins = obj.keep_array(img_block_idx );
            npix_block(~keep_page_bins) = 0;

            keep_pix  = repelem(keep_page_bins,npix_block);
            page_data =  obj.page_data_(:,keep_pix);
            % remove first operand pixels which have zeros in second operand image
            obj.sigvar1.sig_var    = page_data(obj.sigvar_idx_,:);

            fp_sig   = repelem(obj.operand.s(img_block_idx),npix_block);
            fp_var   = repelem(obj.operand.e(img_block_idx),npix_block);
            % ensure row order
            fake_pix = sigvar(fp_sig(:)',fp_var(:)');

            % Do operation
            if obj.flip
                res = obj.op_handle(fake_pix ,obj.sigvar1);
            else
                res = obj.op_handle(obj.sigvar1,fake_pix);
            end
            page_data(obj.sigvar_idx_,:)     = res.sig_var;
            % masked pixels have been dropped. Propagate this.
            obj.page_data_                   = page_data;
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
            % reduce total number of pixels in final image to account for
            % pixels removed from masked bins
            obj.npix_(~obj.keep_array) = 0;
            %
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_,obj.npix_);
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
    end
end