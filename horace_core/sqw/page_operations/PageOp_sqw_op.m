classdef PageOp_sqw_op < PageOp_sqw_eval
    % Single pixel page operation used by sqw_eval function
    %

    methods
        function obj = PageOp_sqw_op(varargin)
            obj = obj@PageOp_sqw_eval(varargin{:});
            obj.op_name_ = 'sqw_op';
        end
        function obj = init(obj,sqw_obj,operation,op_param,average)
            obj           = init@PageOp_sqw_eval(obj,sqw_obj,operation,op_param,average);
            %
            if ~isa(sqw_obj,'sqw') 
                error('HORACE:PageOp_sqw_op:invalid_argument', ...
                    'This operation can be only applied to sqw objects')
            end
        end
        function obj = apply_op(obj,npix_block,npix_idx)
            if obj.average
                qw = obj.page_data_(obj.coord_idx,:);
                qw_pix_coord =  {qw(1,:)',qw(2,:)',qw(3,:)',qw(4,:)'};
                %
                qw_ave =average_bin_data(npix_block,qw_pix_coord);
                % transpose pixels into column form
                qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
                new_signal = obj.op_holder(qw_ave{:}, obj.op_parms{:});
                new_signal = repelem(new_signal, npix_block(:));
            else
                page_data = obj.op_holder(obj, obj.op_parms{:});
            end
            obj.page_data_ = page_data;
            %
            obj = update_img_accumulators(obj,npix_block,npix_idx, ...
                page_data(obj.signal_idx_,:),page_data(obj.var_idx_,:));
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
