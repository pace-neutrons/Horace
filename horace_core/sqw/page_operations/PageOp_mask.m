classdef PageOp_mask < PageOpBase
    % Single page pixel operation used by
    % mask/mask_pixels/mask_random_fraction_pixels/mask_random_pixels
    % methos
    %
    properties
        % the object containing information on what to keep
        keep_info_obj;
        %
        % property, which is true if keep_info provided defiles to bins
        % or false, if it defines pixels to keep
        mask_by_obj;
        mask_by_bins;
        mask_by_num;
        % accumulator for reduced number of pixels
        npix_acc;
        % as this method modifies pixels, it may remove some run_id-s
        % we need to check unique runid (see parent for exp_modified property)
        check_runid
    end
    properties(Dependent)
        % number of pixels in the masked dataset
        num_pix_original;
        % number of bins in the masked dataset
        num_bins;
    end

    methods
        function obj = PageOp_mask(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'masking';
        end

        function obj = init(obj,in_obj,keep_info)
            obj = init@PageOpBase(obj,in_obj);

            if isa(keep_info,'SQWDnDBase')
                obj.keep_info_obj   = keep_info.pix;
            else
                obj.keep_info_obj   = keep_info(:);
            end

            if ~isempty(obj.img_)
                obj.var_acc_ = zeros(numel(obj.img_.npix),1);
                obj.npix_acc = zeros(numel(obj.img_.npix),1);
                obj.check_runid = true;
            else
                % we may want to check for unique run_id to remove
                % unnecessary experiments, but if it is only pixels -- no
                % point.
                obj.check_runid = false;
            end
            % Mask validity and its compartibility with masked object have
            % been verified earlier
            if isa(obj.keep_info_obj,'PixelDataBase')
                obj.mask_by_obj  = true;
                obj.mask_by_bins = false;
                obj.mask_by_num  = false;
                obj.split_at_bin_edges = false;
            elseif isnumeric(keep_info) || islogical(keep_info)
                if isscalar(keep_info)
                    obj.mask_by_obj  = false;
                    obj.mask_by_bins = false;
                    obj.mask_by_num  = true;
                    obj.split_at_bin_edges = false;
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
                        obj.split_at_bin_edges = true;
                    elseif obj.num_pix_original == numel(keep_info)
                        obj.mask_by_bins = false;
                        obj.split_at_bin_edges = false;
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
            if obj.changes_pix_only
                return;
            end
            % calculate changes in npix:
            nbins = numel(npix_block);
            ibin  = repelem(1:nbins, npix_block(:))';
            npix_block = accumarray(ibin(keep_pix), ones(1, sum(keep_pix)), [nbins, 1]);

            % retrieve masked signal and error
            signal = obj.page_data_(obj.signal_idx,:);
            error  = obj.page_data_(obj.var_idx,:);
            % update image accumulators:
            obj = obj.update_img_accumulators(npix_block,npix_idx, ...
                signal,error);
            obj.npix_acc(npix_idx(1):npix_idx(2))    = ...
                obj.npix_acc(npix_idx(1):npix_idx(2))  + npix_block(:);
        end
        %
        function [out_obj,obj] = finish_op(obj,out_obj)
            % update npix with accumulator, accounting for change in
            % npix due to masked pixels
            obj.npix = obj.npix_acc;
            if ~obj.changes_pix_only
                %
                if numel(obj.unique_run_id_) == out_obj.experiment_info.n_runs
                    obj.check_runid = false; % this will not write experiment info
                    % again as it has not changed
                else
                    % it always have to be less or equal, but some tests do not
                    % have consistent Experiment
                    if numel(obj.unique_run_id_) < out_obj.experiment_info.n_runs
                        out_obj.experiment_info = ...
                            out_obj.experiment_info.get_subobj(obj.unique_run_id_);
                    end
                end
            end
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);

        end
        %------------------------------------------------------------------
        function np = get.num_pix_original(obj)
            np = obj.pix_.num_pixels;
        end
        function nb = get.num_bins(obj)
            nb = numel(obj.npix);
        end
        %
        function pieces = calc_page_share(obj,num_pix_to_keep,tot_num_pix,page_size)
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

            % identify the sizes of each page the data were split
            pages     = obj.split_into_pages(tot_num_pix,page_size);
            %
            pages     = [pages{:}];
            num_pages = numel(pages);
            pieces    = floor(pages*pix_share);
            % ensure each page contains at least one pixel.
            nothing   = pieces == 0;
            pieces(nothing) = pieces(nothing)+1;
            %
            splitted = sum(pieces);

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
    methods(Access=protected)
        function is = get_exp_modified(obj)
            % getter for exp_modified property, which saves modified
            % Experiment if set to true
            is = obj.old_file_format_||obj.check_runid;
        end
    end

end