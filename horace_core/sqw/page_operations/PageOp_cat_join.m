classdef PageOp_cat_join < PageOpBase
    % Single page pixel operation used by
    % cat/join operations.
    %
    %
    properties
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
        function obj = PageOp_cat_join(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'cat_join';
        end

        function obj = init(obj,varargin)
            in_obj = obj.check_and_combine_images(varargin{:});
            obj = init@PageOpBase(obj,in_obj);

            if ~isempty(obj.img_)
                obj.var_acc_ = zeros(numel(obj.img_.npix),1);
                obj.npix_acc = zeros(numel(obj.img_.npix),1);
                obj.check_runid = true;
            else
                % if we work with pixels only, we do not need to check
                % runid.
                obj.check_runid = false;
            end
        end

        function obj = get_page_data(obj,idx,varargin)
            % return block of data used in page operation
            %
            % This is most common form of the operation. Some operations
            % will request overloading
            obj.pix_.page_num = idx;
            obj.page_data_ = obj.pix_.data;
        end
        
        function obj = apply_op(obj,npix_block,npix_idx)

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
            [s_ar, e_ar] = compute_bin_data(npix_block,signal,error,true);
            obj.npix_acc(npix_idx(1):npix_idx(2))    = ...
                obj.npix_acc(npix_idx(1):npix_idx(2)) + npix_block(:);
            obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
            obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar(:);
        end
        %
        function [out_obj,obj] = finish_op(obj,out_obj)
            if ~obj.changes_pix_only
                obj = obj.update_image(obj.sig_acc_,obj.var_acc_,obj.npix_acc);
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
    end
    methods(Access=protected)
        function is = get_exp_modified(obj)
            % getter for exp_modified property, which saves modified
            % Experiment if set to true
            is = obj.old_file_format_||obj.check_runid;
        end
    end

end