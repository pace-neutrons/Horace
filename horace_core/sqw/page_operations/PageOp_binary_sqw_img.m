classdef PageOp_binary_sqw_img < PageOp_bin_Base
    % Single page pixel operation used by
    % binary operation manager and applied to two sqw objects and
    % number or array of numbers with size 1, numel(npix) or
    % PixelData.n_pixels
    %
    %
    properties
        keep_array;
    end
    methods
        function obj = PageOp_binary_sqw_img(varargin)
            obj = obj@PageOp_bin_Base(varargin{:});
        end

        function obj = init(obj,w1,operand,operation,flip,npix)
            % The operations is for operands with not-unit size images.
            % The PageOp would not be called for other cases.
            %
            % This operation works with npix array with sum(npix)==pix.num_pixels
            % Three sources of npix are possible:
            % 1) 1st-operand sqw -- does not need check as sqw assumed
            %    valid
            % 2) provided as input -- validated by parent init
            % 3) DnD object with npix
            % if 2nd-operand does not contain npix, it has to be defined
            % in one of 3 ways above and its shape should coincide with
            % shape of the 1st-operand image. Pixels only always contained
            % in [1,1] image.
            if nargin<6
                npix = [];
            end
            [obj,name1_op] = init@PageOp_bin_Base(obj,w1,operand,operation,flip,npix);
            if isnumeric(operand)
                name2_op = 'image-size array';
            else
                name2_op = class(operand);
            end
            obj = obj.set_op_name(name1_op,name2_op);

            if ~isempty(npix)
                npix_provided = true;
            else
                npix_provided = false;
            end
            % HERE WE MAY HAVE: 1) DnDBase, 2) IX_dataset,3) sigvar, or 4) numeric
            % array. All sizes verified to be image size by binary_op_manager.
            % so here we do crude check

            % 1) if second operand is dnd_base operand
            if  isa(obj.operand,'DnDBase') % we need to reconcile operation
                %  agains first operand pixels arrangement.
                if npix_provided
                    error('HORACE:PageOp_binary_sqw_img:invalid_argument', ...
                        'external npix input and second operand of DnD-type are not compartible')
                end
                % need to remove pixels in places where  second operand
                % does not have pixels (operand.npix == 0)
                obj.keep_array = logical(obj.operand.npix(:));
                if  numel(obj.npix)== 1 % 1st operand is npix only and class
                    % npix is not defined above.
                    % pix <-> DnDBase operation. Needs to be done in npix steps
                    if sum(obj.operand.npix(:)) ~= obj.pix_.num_pixels
                        nobj1_elements = obj.pix_.num_pixels;
                        nobj2_elements = sum(obj.operand.npix(:));
                        error('HORACE:PageOp_binary_sqw_img:invalid_argument', ...
                            ['%s attempted between inconsistent objects.\n' ...
                            '%s contains %d pixels and obj %s addresses %d pixels'], ...
                            obj.op_name_,name1_op,nobj1_elements, ...
                            name2_op,nobj2_elements);
                    end
                    % define npix
                    obj.npix = obj.operand.npix(:);
                else % shapes of images have already been validated, and
                    % operation have to be performed over 1st operand npix
                end
                nobj2_elements = numel(obj.operand.npix);
            else % not DnD
                obj.keep_array = true(size(obj.npix));

                % npix and keep_array are defined and verified here for any
                % possible input situation.
                %
                % 2) sigvar. Its mask may contain information on what pixels to
                % retain. If mask is not defined, this info will be ignored
                if isa(obj.operand,'sigvar')
                    if obj.operand.is_mask_defined
                        obj.keep_array = obj.operand.mask;
                    end
                    nobj2_elements = obj.operand.n_elements;

                elseif isa(obj.operand,'IX_dataset') || isnumeric(obj.operand)
                    % 3-4) IX_dataset || Numeric
                    obj.operand = sigvar(obj.operand);
                    nobj2_elements = obj.operand.n_elements;
                else
                    % could not get here in any case? Only if called from
                    % op_manager
                    error('HORACE:PageOp_binary_sqw_img:invalid_argument', ...
                        'Unsupported class %s of second operand for operation %s',...
                        class(obj.operand),obj.op_name);
                end
            end
            % Are operation members consistent? This check is normally
            % performed by binary_op_manager and here it is for cases
            % where calls to class do not use it (tests and redundant pix
            % only methods)
            nobj1_elements  = numel(obj.npix);
            if nobj1_elements ~= nobj2_elements
                name1_obj = class(w1);
                name2_obj = class(operand);
                error('HORACE:PageOp_binary_sqw_img:invalid_argument', ...
                    ['%s attempted between inconsistent objects.' ...
                    ' Image of operand1: %s has %d elements' ...
                    ' and img of op2 %s has %d elements'], ...
                    obj.op_name_,name1_obj,nobj1_elements, ...
                    name2_obj,nobj2_elements);
            end
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
                res = binary_op_manager_single( ...
                    fake_pix,obj.sigvar1,obj.op_handle);
            else
                res = binary_op_manager_single( ...
                    obj.sigvar1,fake_pix,obj.op_handle);
            end
            page_data(obj.sigvar_idx_,:)     = res.sig_var;
            % masked pixels have been dropped. Propagate this.
            obj.page_data_                   = page_data;
            if obj.changes_pix_only
                return;
            end
            % update image accumulators:
            obj = update_img_accumulators(obj,npix_block,npix_idx,res.s,res.e);
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