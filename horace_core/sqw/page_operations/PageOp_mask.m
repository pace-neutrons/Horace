classdef PageOp_mask < PageOpBase
    % Single page pixel operation used by
    % mask/mask_pixels/mask_random_fraction_pixels/mask_random_pixels
    % methos
    %
    properties
        % the object containing information on what
        keep_info_obj;
        %

        % property, which is true if keep_info provided defiles to bins
        % or false, if it defines pixels to keep
        mask_by_obj;
        mask_by_bins;
        mask_by_num;
        % accumulator for reduced number of pixels
        npix_acc;
    end
    properties(Dependent)
        % number of pixels in the masked dataset
        num_pix_original;
        % number of bins in the masked dataset
        num_bins;
    end

    methods
        function [obj,in_obj] = init(obj,in_obj,keep_info)
            [obj,in_obj] = init@PageOpBase(obj,in_obj);

            if isa(keep_info,'SQWDnDBase')
                obj.keep_info_obj   = keep_info.pix;
            else
                obj.keep_info_obj   = keep_info(:);
            end

            if ~isempty(obj.img_)
                obj.var_acc_ = zeros(numel(obj.img_.npix),1);
                obj.npix_acc = zeros(numel(obj.img_.npix),1);
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
                    if obj.pix_.num_pages> 1 % each page should contain
                        % share of the requested number of pixels
                        obj.keep_info_obj = obj.calc_page_share( ...
                            keep_info,obj.num_pix_original,obj.pix_.page_size);
                    end
                else
                    obj.mask_by_obj  = false;
                    obj.mask_by_num  = false;
                    if obj.num_bins == numel(keep_info)
                        obj.mask_by_bins = true;
                    elseif obj.num_pix_original == numel(keep_info)
                        obj.mask_by_bins = false;
                    else
                        error('HORACE:PageOp_mask:invalid_argument', ...
                            'Number of masking elements in array must be equal to number of pixels (%d) or number of bins (%d). It is %d',...
                            obj.num_pix_original,numel(npix),numel(keep_info))
                    end
                end
            else
                error('HORACE:PageOp_mask:invalid_argument', ...
                    ['keep_info can be either sqw/PixData object, containing information about masking\n', ...
                    'or array/logical array or numbers specifying pixels/bins to mask'] )
            end
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            obj.page_data_ = obj.pix_.data;

            % create pixel mask
            if obj.mask_by_num
                % get masks which keeps specific number of pixels on a
                % particular page.
                % keep on the page:
                num_keep_here = obj.keep_info_obj(obj.page_num);
                num_pix_here = sum(npix_block(:));
                % genereate mask
                keep_pix = false(1,num_pix_here);
                keep_pix(randperm(num_pix_here, num_keep_here)) = true;
            elseif obj.mask_by_bins
                % create pixels selection by selecting whole pixel ranges
                % corresponding to bins
                keep_pix = repelem(obj.keep_info_obj(npix_idx(1):npix_idx(2)), npix_block(:));
            elseif obj.mask_by_obj
                % if masking is filebacked, its pixel size must be
                % equal to the object size, which currently always true
                % as we have single page size
                obj.keep_info_obj.page_num = obj.page_num;
                % keep where signal is bigger then 1
                mask_data = obj.keep_info_obj.signal;
                keep_pix = mask_data>=1;
            else % mask by numerical or logical array of npix_size
                [pix_idx_start, pix_idx_end] = obj.pix_.get_page_idx_();
                keep_pix = obj.keep_info_obj(pix_idx_start:pix_idx_end);
            end
            % keep what is selected
            obj.page_data_ = obj.page_data_(:,keep_pix);
            if isempty(obj.img_)
                return;
            end
            % calculate changes in npix:
            nbins = numel(npix_block);
            %ibin = replicate_array(1:nbins,npix_block); % equilalent operations
            ibin = repelem(1:nbins, npix_block(:))';     % What to select, what is more efficient?
            npix_block = accumarray(ibin(keep_pix), ones(1, sum(keep_pix)), [nbins, 1]);

            % caclulate new signal and error
            signal = obj.page_data_(obj.signal_idx,:);
            error  = obj.page_data_(obj.var_idx,:);
            [s_ar, e_ar] = compute_bin_data(npix_block,signal,error,true);
            obj.npix_acc(npix_idx(1):npix_idx(2))    = ...
                obj.npix_acc(npix_idx(1):npix_idx(2)) + npix_block;
            obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar;
            obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar;
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            if ~isempty(obj.img_)
                sz = size(obj.img_.s);
                nopix = obj.npix_acc == 0;
                calc_sig = obj.sig_acc_(:)./obj.npix_acc(:);
                calc_var = obj.var_acc_(:)./obj.npix_acc(:).^2;

                calc_sig(nopix) = 0;
                calc_var(nopix) = 0;
                obj.img_.s    = reshape(calc_sig,sz);
                obj.img_.e    = reshape(calc_var,sz);
                obj.img_.npix = reshape(obj.npix_acc,sz);
            end
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
        %------------------------------------------------------------------
        function np = get.num_pix_original(obj)
            np = obj.pix_.num_pixels;
        end
        function nb = get.num_bins(obj)
            nb = numel(obj.npix);
        end
        %
    end
    methods(Static)
        function pieces = calc_page_share(num_pix_to_keep,tot_num_pix,page_size)
            % Helper function used in keeping part of pixels from total
            % number of pixels in a dataset.
            %
            % Splits the total number of pixels to keep into the array of
            % numbers of pixels  to keep on each pixel's page.
            %
            % Inputs:
            % num_pix_to_keep -- number of pixels to keep from the whole
            %                    number of pixels.
            % tot_num_pix     -- total number of pixels to reduce by
            %                    masking
            % page_size       -- the size of the page
            %
            %
            pix_share = num_pix_to_keep/tot_num_pix;
            pages     = split_vector_fixed_sum(tot_num_pix,page_size);
            pages     = [pages{:}];
            num_pages = numel(pages);
            pieces    = floor(pages*pix_share);
            % ensure each page contains at least one pixel.
            nothing   = pieces == 0;
            pieces(nothing) = pieces(nothing)+1;
            %
            splitted = sum(pieces);
            while splitted<num_pix_to_keep
                ic = num_pages;
                while ic>0 && splitted<num_pix_to_keep
                    pieces(ic) = pieces(ic)+1;
                    if pieces(ic) < pages(ic)
                        splitted = splitted+1;
                    else
                        pieces(ic) = pages(ic);
                    end
                    ic = ic-1;
                end
            end
        end
    end
end