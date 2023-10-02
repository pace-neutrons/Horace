classdef PageOp_mask < PageOpBase
    % Single page pixel operation used by
    % mask/mask_pixels/mask_random_fraction_pixels/mask_random_pixels
    % methos
    %
    properties
        % the object containing information on what
        keep_info_obj;
        %
        num_pix_original;
        num_bins_original;
        % property, which is true if keep_info provided defiles to bins
        % or false, if it defines pixels to keep
        mask_by_obj;
        mask_by_bins;
        mask_by_num;
    end

    methods
        function [obj,in_obj] = init(obj,in_obj,keep_info)
            [obj,in_obj] = init@PageOpBase(obj,in_obj);
            if isa(keep_info,'SQWDnDBase')
               obj.keep_info_obj= keep_info.pix;
            else
                obj.keep_info_obj    = keep_info;                
            end          

            obj.num_pix_original = in_obj.num_pixels;
            if ~isempty(obj.img_)
                obj.num_bins_original = numel(obj.img_.npix);
            end
            % Mask validity and its compartibility with masked object have
            % been verified earlier 
            if isa(obj.keep_info_obj,'PixelDataBase')
                obj.mask_by_obj  = true;
                obj.mask_by_bins = false;
                obj.mask_by_num  = false;
            elseif isnumeric(keep_info) || islogical(keep_info)
                if isscalar(keep_info)
                    obj.mask_by_obj  = false;
                    obj.mask_by_bins = false;
                    obj.mask_by_num  = true;
                else
                    obj.mask_by_obj  = false;
                    obj.mask_by_num  = false;
                    if ~isempty(obj.img_)
                        if numel(obj.img_.npix) == numel(keep_info)
                            obj.mask_by_bins = true;
                        elseif obj.num_pix_original == numel(keep_info)
                            obj.mask_by_bins = false;
                        else
                            error('HORACE:PageOp_mask:invalid_argument', ...
                                'Number of masking elements in array must be equal to number of pixels (%d) or number of bins (%d). It is %d',...
                                obj.num_pix_original,numel(obj.img_.npix),numel(keep_info))
                        end
                    else
                        obj.mask_by_bins = false;
                    end
                end
            else
                error('HORACE:PageOp_mask:invalid_argument', ...
                    ['keep_info can be either sqw/PixData object, containing information about masking\n', ...
                    'or array/logical array or numbers specifying pixels/bins to mask'] )
            end
        end

        function [obj,page_data] = apply_op(obj,npix_block,npix_idx,pix_idx1,pix_idx2)
            single_page = nargin == 2;
            if single_page
                page_data = obj.pix_.data;
                if obj.mask_by_num
                    num_pix_here = obj.num_pix_original;
                    num_keep_here = obj.keep_info_obj;
                end                
            else
                page_data = obj.pix_.get_pixels(pix_idx1:pix_idx2,'-raw');
                if obj.mask_by_num
                    num_pix_here = sum(npix_block);
                    num_keep_here    = round(num_pix_here*(obj.keep_info_obj/obj.num_pix_original));
                end
            end

            if obj.mask_by_num
                % create pixel mast
                keep = false(1,num_pix_here);
                keep(randperm(num_pix_here, num_keep_here)) = true;
                % calculate change in npix
                ind = repelem(idx,npix_block);
                ind = ind(keep);
                npix_block = accumarray(ind,ones(numel(npix_block),1));
                % keep what is selected
                page_data = page_data(:,keep);
                pix_fld_idx = PixelDataBase.field_index({'signal','variance'});
                % caclulate new signal and error 
                signal = page_data(pix_fld_idx(1),:);
                error  = page_data(pix_fld_idx(2),:);    
                [s_ar, e_ar] = average_bin_data(npix_block, {signal,error});                
            elseif obj.mask_by_bins
            else
            end

            if single_page
                obj.img_.s           = s_ar;
                obj.img_.e           = e_ar;                
            else
                obj.img_.s(npix_idx(1):npix_idx(2)) = s_ar;
                obj.img_.s(npix_idx(1):npix_idx(2)) = e_ar;                
            end
            page_data = page_pix.data;

        end
        function [out_obj,obj] = finish_op(obj,out_obj)
            %
            obj.img_.e = zeros(size(obj.img_.s));
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end

    end
end