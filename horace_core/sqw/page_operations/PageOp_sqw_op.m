classdef PageOp_sqw_op < PageOp_sqw_eval
    % Single pixel page operation used by sqw_eval function
    %
    properties % exposed PageOp protected properties to be able to 
        % use them in sqw_op 
        page_data;  % block of pixel data, loaded in memory
    end
    methods
        function pd = get.page_data(obj)
            pd = obj.page_data_;
        end
    end

    methods
        function obj = PageOp_sqw_op(varargin)
            obj = obj@PageOp_sqw_eval(varargin{:});
            obj.op_name_ = 'sqw_op';
        end
        function obj = init(obj,sqw_obj,operation,op_param,average)
            obj           = init@PageOp_sqw_avel(obj,sqw_obj,operation,op_param,average);
            %
            if ~isa(sqw_obj,'sqw') 
                error('HORACE:PageOp_sqw_op:invalid_argument', ...
                    'This operation can be only applied to sqw objects')
            end
        end
        function obj = update_img_accumulators(obj,npix_block,npix_idx, ...
                new_signal,varargin)
            % specific overload for sqw_eval. Variance accumulator is not
            % initialized for it, and call to compute_bin_data accepts only
            % one argument
            img_signal = compute_bin_data(npix_block,new_signal,[],true);
            obj.sig_acc_(npix_idx(1):npix_idx(2)) = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2))+img_signal(:);
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            qw = obj.proj.transform_pix_to_hkl(obj.page_data_(obj.coord_idx,:));
            qw_pix_coord =  {qw(1,:)',qw(2,:)',qw(3,:)',qw(4,:)'};
            if obj.average
                % Get average h, k, l, e for the bin, compute sqw for that average,
                % and fill pixels with the average signal for the bin that contains
                % them
                qw_ave =average_bin_data(npix_block,qw_pix_coord);
                % transpose pixels into column form
                qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
                new_signal = obj.op_holder(qw_ave{:}, obj.op_parms{:});
                new_signal = repelem(new_signal, npix_block(:));
            else
                new_signal = obj.op_holder(qw_pix_coord{:}, obj.op_parms{:});
            end
            obj.page_data_(obj.signal_idx,:)   = new_signal(:)';
            obj.page_data_(obj.var_idx,:)      = 0; % I do not like this but this is legacy behaviour
            %
            obj = update_img_accumulators(obj,npix_block,npix_idx, ...
                new_signal);
        end

        function [out_obj,obj] = finish_op(obj,out_obj)
            % transfer modifications to the underlying object
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end
    end
    methods(Access=protected)
        % Log frequency
        %------------------------------------------------------------------
        function rat = get_info_split_log_ratio(~)
            rat = config_store.instance().get_value('log_config','sqw_eval_split_ratio');
        end
        function obj = set_info_split_log_ratio(obj,val)
            log = log_config;
            log.sqw_eval_split_ratio = val;
        end
    end
end
