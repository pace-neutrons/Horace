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
                        npix = obj.img_.npix;
                    elseif ~isempty(obj.npix_)
                        npix = obj.npix_;
                    else
                        npix = [];
                        obj.mask_by_bins = false;
                    end
                    if ~isempty(npix)
                        if numel(npix) == numel(keep_info)
                            obj.mask_by_bins = true;
                        elseif obj.num_pix_original == numel(keep_info)
                            obj.mask_by_bins = false;
                        else
                            error('HORACE:PageOp_mask:invalid_argument', ...
                                'Number of masking elements in array must be equal to number of pixels (%d) or number of bins (%d). It is %d',...
                                obj.num_pix_original,numel(npix),numel(keep_info))
                        end
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
            else
                page_data = obj.pix_.get_pixels(pix_idx1:pix_idx2,'-raw');
            end

            if obj.mask_by_num
                % create pixel mask
                if single_page
                    num_pix_here  = obj.num_pix_original;
                    num_keep_here = obj.keep_info_obj;
                else
                    num_pix_here  = sum(npix_block);
                    num_keep_here = round(num_pix_here*(obj.keep_info_obj/obj.num_pix_original));
                end
                keep_pix = false(1,num_pix_here);
                keep_pix(randperm(num_pix_here, num_keep_here)) = true;
            elseif obj.mask_by_bins
                % create pixels selection by selecting whole pixel ranges
                % corresponding to bins
                if single_page
                    keep_pix = repelem(obj.keep_info_obj(:), npix_block(:));
                else
                    keep_pix = repelem(obj.keep_info_obj(npix_idx(1):npix_idx(2)), npix_block);
                end
            elseif obj.mask_by_obj
                if single_page % get  information from masking object
                    mask_data = obj.keep_info_obj.signal;
                else  % if masking is filebacked, its pixel size must be
                    % equal to the object size.
                    mask_data = obj.keep_info_obj.get_pixels(pix_idx1:pix_idx2,'signal','-raw');
                end
                keep_pix = mask_data>=1;
            else % mask by numerical or logical array of npix_size
                if single_page
                    keep_pix = obj.keep_info_obj;
                else
                    keep_pix = obj.keep_info_obj(pix_idx1:pix_idx2);
                end
            end
            % keep what is selected
            page_data = page_data(:,keep_pix);
            if isempty(obj.img_)
                if single_page
                    obj.pix_ = obj.pix_.set_raw_data(page_data);
                end
                return;
            end
            % calculate change in npix
            nbins = numel(npix_block);
            %ibin = replicate_array(1:nbins,npix_block); % equilalent operations
            ibin = repelem(1:nbins, npix_block(:))';     % What to select, what is more efficient?
            npix_block = accumarray(ibin(keep_pix), ones(1, sum(keep_pix)), [nbins, 1]);

            % caclulate new signal and error
            signal = page_data(obj.signal_idx,:);
            error  = page_data(obj.var_idx,:);
            [s_ar, e_ar] = compute_bin_data(npix_block,signal,error);

            if single_page
                sz = size(obj.img_.npix);
                obj.img_.npix        = reshape(npix_block,sz);
                obj.img_.s           = reshape(s_ar,sz);
                obj.img_.e           = reshape(e_ar,sz);
                obj.pix_ = obj.pix_.set_raw_data(page_data);
            else
                obj.img_.npix(npix_idx(1):npix_idx(2)) = npix_block;
                obj.img_.s(npix_idx(1):npix_idx(2))    = s_ar;
                obj.img_.e(npix_idx(1):npix_idx(2))    = e_ar;
            end
        end
    end
end