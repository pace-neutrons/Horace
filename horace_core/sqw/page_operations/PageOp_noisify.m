classdef PageOp_noisify < PageOpBase
    % Single pixel page operation used by noisify function
    %
    properties
        % processed input parameters of the noisify routine
        noisify_par
        %
    end
    methods
        function obj = PageOp_noisify(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'noisify';
            obj.split_at_bin_edges = false;
        end
        function obj = init(obj,sqw_obj,varargin)
            obj           = init@PageOpBase(obj,sqw_obj);
            %
            if ~obj.changes_pix_only
                obj.var_acc_ = zeros(numel(obj.npix),1);
            end
            [~,~,obj.noisify_par] = noisify([],[],varargin{:});
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            [signal,var]= noisify( ...
                obj.page_data_(obj.signal_idx,:),obj.page_data_(obj.var_idx,:), ...
                obj.noisify_par);
            obj.page_data_(obj.signal_idx,:)   = signal(:)';
            obj.page_data_(obj.var_idx,:)      = var(:)';

            obj = obj.update_img_accumulators(npix_block,npix_idx, ...
                signal,var);
        end
        %
        function print_range_warning(obj,infile_name,is_old_file_format)
            % print missing range message specific for noisify function.
            %
            [~,fn,fe] = fileparts(infile_name);
            if is_old_file_format
                upgrade_message = obj.gen_old_file_message(infile_name);
            else
                upgrade_message = obj.gen_misaligned_file_message(infile_name);
            end
            fprintf(2,[ '\n', ...
                '*** Source SQW file %s does not contain correct pixel data ranges.\n', ...
                '*** noisify uses these ranges so pre-calculates them using recompute_bin_data algorithm.\n', ...
                '*** Upgrade your original sqw object to contain these averages\n', ...
                '    and not to recalculate them each time the averages are requested\n', ...
                '%s' ], ...
                [fn,fe],upgrade_message);

        end
    end
    methods(Access=protected)
        function do = get_do_missing_range_warning(~)
            % noisify should not produce range warning, as its range is
            % calculated by other algorithm.
            do  = false;
        end
        % Log frequency
        %------------------------------------------------------------------
        function rat = get_info_split_log_ratio(~)
            rat = config_store.instance().get_value('log_config','noisify_split_ratio');
        end
        function obj = set_info_split_log_ratio(obj,val)
            log = log_config;
            log.noisify_split_ratio = val;
        end
    end
end
