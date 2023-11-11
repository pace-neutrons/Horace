classdef PageOp_binary_sqw_sqw < PageOp_bin_Base
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
        % if this property is true, we ignore pixels order within the bins
        % and assume that the order of pixels wrt operation is the same.
        % HACK: Re #1371 -- see if this is justified. Hotfix for some current
        % tests to run.
        ignore_pix_order = true;
    end

    methods
        function obj = PageOp_binary_sqw_sqw(varargin)
            obj = obj@PageOp_bin_Base(varargin{:});
        end

        function obj = init(obj,w1,operand,operation,flip,varargin)
            %
            [obj,name_op1] = init@PageOp_bin_Base(obj,w1,operand,operation,flip,varargin{:});
            %
            if isa(operand,'sqw')
                name_op2 = 'sqw';
                obj.operand = operand.pix;
            else
                name_op2   = 'pix';
            end
            obj = obj.set_op_name(name_op1,name_op2);

            if obj.pix_.num_pixels ~= obj.operand.num_pixels
                error('HORACE:PageOp_binary_sqw_sqw:invalid_argument', ...
                    'Pixels in %s are inconsistent as obj1 has %d pixels and obj2 has %d pixels', ...
                    obj.op_name_,obj.pix_.num_pixels,obj.operand.num_pixels);
            end

            if numel(obj.npix) == 1 % usually pixel-only operations or d0d
                obj.scalar_input_ = true;
            end
        end
        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % Overloaded for dealing with two PixelData objects
            [obj,pix_idx] = get_page_data@PageOp_bin_Base(obj,idx,npix_blocks);
            page_data2    = obj.operand.get_pixels(pix_idx,'-raw');
            if ~obj.ignore_pix_order
                % sort pixels as they usually randomly distributed
                % within the bins. These are the pixel indexes within the npix
                % chunk
                npix_block = npix_blocks{idx};
                chunk_idx = repelem(1:numel(npix_block),npix_block);
                % sort first pages by rows and then by all 3 pix_idx, defining
                % neutron event
                [~,idx1]  = sortrows([chunk_idx;obj.page_data_(obj.all_idx_,:)]');
                [~,idx2]  = sortrows([chunk_idx;    page_data2(obj.all_idx_,:)]');
                obj.page_data_ = obj.page_data_(:,idx1);
                page_data2     =     page_data2(:,idx2);
            end
            % Here we may introduce check to ensure pixels coordinates are
            % indeed equal for this operation to be correct.
            % == check here
            % Or we may trust the user. The chance of them finding two
            % objects with the same pixel-bin distribution and different
            % pix coordinates are slim.

            % prepare operands for binary operation
            obj.sigvar1.sig_var = obj.page_data_(obj.sigvar_idx_,:);
            obj.sigvar2.sig_var =     page_data2(obj.sigvar_idx_,:);
        end


        function obj = apply_op(obj,npix_block,npix_idx)
            % Do operation
            res = binary_op_manager_single( ...
                obj.sigvar1,obj.sigvar2,obj.op_handle);
            obj.page_data_(obj.sigvar_idx_,:) = res.sig_var;
            if obj.changes_pix_only
                return;
            end
            % update image accumulators:
            obj = update_img_accumulators(obj,npix_block,npix_idx,res.s,res.e);
        end
    end
end