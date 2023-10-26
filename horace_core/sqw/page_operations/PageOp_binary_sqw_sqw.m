classdef PageOp_binary_sqw_sqw < PageOpBase
    % Single page pixel operation used by
    % binary operation manager and applied to two sqw objects with identical
    % pixels distribution over bins
    %
    % TODO: its not too difficult to expand this onto two sqw objects with
    %       different pix distributions and different number of pixels
    %       using the approach, applied for operations with sqw-dnd objects
    %       Left for future discussion: Re #1358.
    %
    properties
        % property contains handle to function, which performs operation
        op_handle;
        % contains pixels from second object participating in operation
        pix2_;
    end
    properties(Access = private)
        pix_idx_start_ = 1;
        % location of fields, containing all indices defining neutron event
        all_idx_
        % indices of signal and variance fields in pixels
        sigvar_idx_
        % Preallocate two operands, participating in operation
        sigvar1 = sigvar();
        sigvar2 = sigvar();
    end



    methods
        function obj = PageOp_binary_sqw_sqw(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.all_idx_ = PixelDataBase.field_index('all_indexes');
            obj.sigvar_idx_ = PixelDataBase.field_index('sig_var');
        end

        function obj = init(obj,w1,w2,operation)
            obj = init@PageOpBase(obj,w1);
            if isa(w2,'sqw')
                name2_obj = 'sqw';
                obj.pix2_ = w2.pix;
            else
                name2_obj = 'pix';
                obj.pix2_ = w2;
            end
            if isempty(obj.img_)
                name1_obj = 'pix';
            else
                name2_obj = 'sqw';                
            end
            obj.op_handle = operation;
            obj.op_name_ = sprintf('binary op: %s between %s and %s objects', ...
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
            % Overload specific for sqw_sqw binary operation
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

            obj.page_data_ = obj.pix_.get_pixels( ...
                obj.pix_idx_start_:pix_idx_end,'-raw');
            page_data2    = obj.pix2_.get_pixels( ...
                obj.pix_idx_start_:pix_idx_end,'-raw');
            % sort pixels as they usually randomly distributed
            % within the bins. These are the pixel indexes
            chunk_idx = repelem(1:npix,npix_block);
            % sort first pages by rows and then by all 3 pix_idx, defining
            % neutron event
            [~,idx1]  = sortrows([chunk_idx,obj.page_data_(obj.all_idx_)]);
            [~,idx2]  = sortrows([chunk_idx,    page_data2(obj.all_idx_)]);
            obj.page_data_ = obj.page_data_(:,idx1);
            page_data2     =     page_data2(:,idx2);
            % Here we may introduce check, to ensure pixels are indeed
            % equal for this operation to be correct.
            % == check here
            % Or we may trust the user.

            % prepare operands for binary operation
            obj.sigvar1.sig_var = obj.page_data_(obj.sigvar_idx_,:);
            obj.sigvar2.sig_var =     page_data2(obj.sigvar_idx_,:);

            obj.pix_idx_start_ = pix_idx_end+1;
        end


        function obj = apply_op(obj,npix_block,npix_idx)
            % Do operation
            res = obj.op_handle(obj.sigvar1,obj.sigvar2);
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