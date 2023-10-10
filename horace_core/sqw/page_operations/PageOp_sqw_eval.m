classdef PageOp_sqw_eval < PageOpBase
    % Single pixel page operation used by sqw_eval function
    %
    properties
        % empty operation
        op_holder = @(h,k,l,e){};
        average = false;
        proj
        op_parms
        %
    end
    properties(Access = private)
        pix_idx_start_ = 1;
    end

    methods
        function obj = PageOp_sqw_eval(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'sqw_eval';
        end
        function [obj,sqw_obj] = init(obj,sqw_obj,operation,op_param,average)
            [obj,sqw_obj] = init@PageOpBase(obj,sqw_obj);
            obj.proj      = sqw_obj.data.proj;
            obj.average   = average;
            obj.op_holder = operation;
            obj.op_parms  = op_param;
            obj.pix_idx_start_ = 1;
            %
        end
        function [npix_chunks, npix_idx] = split_into_pages(obj,npix,chunk_size)
            % Method used to split input npix array into pages
            %
            % Overload specific for sqw_eval
            % Inputs:
            % npix  -- image npix array, which defines the number of pixels
            %           contributing into each image bin and the pixels
            %           ordering in the linear array
            % chunk_size
            %       -- sized of chunks to split pixels
            % Returns:
            % npix_chunks -- cellarray, containing the npix parts
            % npix_idx    -- [2,n_chunks] array of indices of the chunks in
            %                the npix array.
            % See split procedure for more details
            if obj.average
                [npix_chunks, npix_idx] = split_vector_max_sum(npix, chunk_size);
            else
                [npix_chunks, npix_idx] = split_vector_fixed_sum(npix, chunk_size);
            end
        end


        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % Overload specific for sqw_eval. Its average operation needs
            % knolege of all pixel coordinates in a cell.
            npix_block = npix_blocks{idx};
            npix = sum(npix_block(:));
            pix_idx_end = obj.pix_idx_start_+npix-1;
            obj.page_data_ = obj.pix_.get_pixels(obj.pix_idx_start_:pix_idx_end,'-raw');
            obj.pix_idx_start_ = pix_idx_end+1;
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            qw = obj.proj.transform_pix_to_hkl(obj.page_data_(obj.coord_idx,:));
            qw_pix_coord =  {qw(1,:)',qw(2,:)',qw(3,:)',qw(4,:)'};
            if obj.average
                % Get average h, k, l, e for the bin, compute sqw for that average,
                % and fill pixels with the average signal for the bin that contains
                % them
                qw_ave =average_bin_data(npix_block,qw_pix_coord);
                % transpose pixels into column form
                qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
                new_signal = obj.op_holder(qw_ave{:}, obj.op_parms{:});
                new_signal = repelem(new_signal, npix_block(:));
            else
                new_signal = obj.op_holder(qw_pix_coord{:}, obj.op_parms{:});
            end
            obj.page_data_(obj.signal_idx,:)   = new_signal(:)';
            obj.page_data_(obj.var_idx,:)      = 0; % I do not like this but this is legacy behaviour

            img_signal = compute_bin_data(npix_block,new_signal,[],true);
            obj.sig_acc_(npix_idx(1):npix_idx(2)) = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2))+img_signal(:);
        end

        function [out_obj,obj] = finish_op(obj,out_obj)
            variance = zeros(numel(obj.sig_acc_),1); % I do not like this but this is legacy behaviour
            % Complete image modifications:
            obj = obj.update_image(obj.sig_acc_,variance);

            % transfer modifications to the underlying object
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
            obj.pix_idx_start_ = 1;
        end

    end
end