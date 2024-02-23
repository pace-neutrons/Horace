classdef PageOp_recompute_bins < PageOpBase
    % Single pixels page operation which does not change the pixels values
    % unless pixels are misaligned. If they are misaligned, resulting
    % pixels get realigned as the result of operation.
    %
    % Used by recompute_bin_data, finalize_alignment and recalc_data_range
    % algorithms.
    properties(Hidden)
        % sets change_pix_only for true when class is invoked for
        % alignment operation
        img_range
    end
    properties(Access=private)
        changes_pix_only_ = false;
    end
    methods
        function obj = PageOp_recompute_bins(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'recompute_bin_data_and_ranges';
            obj.split_at_bin_edges = true;
        end

        function obj = init(obj,in_obj)
            obj = init@PageOpBase(obj,in_obj);
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
        end
        function obj = apply_op(obj,npix_block,npix_idx)
            if obj.changes_pix_only
                return;
            end
            % retrieve signal and error
            signal = obj.page_data_(obj.signal_idx,:);
            error  = obj.page_data_(obj.var_idx,:);
            % update image accumulators:
            obj = obj.update_img_accumulators(npix_block,npix_idx, ...
                signal,error);
        end
    end
    methods(Access=protected)
        function  does = get_changes_pix_only(obj)
            does = obj.changes_pix_only_||isempty(obj.img_);
        end
        function obj = set_changes_pix_only(obj,val)
            % main setter for changes_pix_only_
            obj.changes_pix_only_ = logical(val);
        end

        function do = get_do_missing_range_warning(~)
            % these operations intended for computing missing range
            % so no point of warning that range is missing
            %
            % TODO: warning may be issued if the data are stored not in the
            % original file
            do  = false;
        end
        % Log frequency
        %------------------------------------------------------------------
        function rat = get_info_split_log_ratio(~)
            rat = config_store.instance().get_value('log_config','recompute_bins_split_ratio');
        end
        function obj = set_info_split_log_ratio(obj,val)
            log = log_config;
            log.recompute_bins_split_ratio = val;
        end
    end
end
