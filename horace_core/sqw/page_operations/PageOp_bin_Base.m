classdef PageOp_bin_Base < PageOpBase
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
    properties(Access = protected)
        % counter for pixels to start operation from
        pix_idx_start_ = 1;
        % location of fields, containing all indices defining neutron event
        all_idx_
        % indices of signal and variance fields in pixels
        sigvar_idx_
        % Preallocate two operands, participating in operation
        sigvar1 = sigvar();
        sigvar2 = sigvar();

        scalar_input_ = false;
    end

    methods
        function obj = PageOp_bin_Base(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.sigvar_idx_ = PixelDataBase.field_index('sig_var');
            obj.all_idx_ = PixelDataBase.field_index('all_indexes');
        end
        function [obj,name1_obj] = init(obj,w1,operand,operation,flip,npix,varargin)
            obj = init@PageOpBase(obj,w1);
            if nargin<5
                flip = false;
            end

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
                    error('HORACE:PageOp_bin_Base:invalid_argument',[ ...
                        'Number of pixels of the first operand (%d) inconsistent ' ...
                        'with their bin-distribution, provided as #5-th argument npix (%d)'], ...
                        obj.pix_.num_pixels,sum(npix(:)));
                end
                obj.npix = npix(:);
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
            % Overload specific for binary operations
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

        function [obj,pix_idx] = get_page_data(obj,idx,npix_blocks)
            % retrieve block of data used in page operation
            %
            % Overloaded for dealing with two PixelData objects
            npix_block = npix_blocks{idx};
            npix = sum(npix_block(:));
            pix_idx_end = obj.pix_idx_start_+npix-1;

            pix_idx = obj.pix_idx_start_:pix_idx_end;
            obj.page_data_ = obj.pix_.get_pixels(pix_idx,'-raw');

            obj.pix_idx_start_ = pix_idx_end+1;
        end
        %
        function obj = update_img_accumulators(obj,npix_block,npix_idx,s,e)
            % update image accumulators:
            [s_ar, e_ar] = compute_bin_data(npix_block,s,e,true);
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
        %
        function obj = set_op_name(obj,obj1_name,obj2_name)
            % Define the name of the binary operation from the class of the
            % participating objects and the name of the operation
            if obj.flip
                name1 = obj2_name;
                name2 = obj1_name;
            else
                name1 = obj1_name;
                name2 = obj2_name;
            end
            obj.op_name_ = ...
                sprintf('binary op: %s between %s and %s', ...
                func2str(obj.op_handle),name1,name2);
        end
    end
end