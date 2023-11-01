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

        function obj = init(obj,w1,operand,operation,flip,npix,keep_array)
            [obj,name1_op] = init@PageOp_bin_Base(obj,w1,operand,operation,flip,npix);

            obj.keep_array= keep_array;
            name2_op = class(operand);            
            obj = obj.set_op_name(name1_op,name2_op);            

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

            is_dnd_base = isprop(obj.operand,'npix');
            if numel(obj.npix)== 1 && is_dnd_base && ~npix_provided 
                % pix <-> DnDBase operation. Needs to be done in npix steps
                obj.npix = obj.operand.npix(:);
            end
            if isa(obj.operand,'IX_dataset')
                obj.operand = sigvar(obj.operand);
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