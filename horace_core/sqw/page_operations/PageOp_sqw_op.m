classdef PageOp_sqw_op < PageOp_sqw_eval
    % Single pixel page operation used by sqw_op algorithm
    %

    methods
        function obj = PageOp_sqw_op(varargin)
            obj = obj@PageOp_sqw_eval(varargin{:});
            obj.op_name_ = 'sqw_op';
        end
        function obj = init(obj,sqw_obj,operation,op_param,average)
            if average
                error('HORACE:PageOp_sqw_op:not_implemented', ...
                    '"-average" option is not currently implemented for sqw_op')
            end
            if ~isa(sqw_obj,'sqw') || sqw_obj.pix.num_pixels == 0
                if isa(sqw_obj,'sqw')
                    mess_out = 'Provided sqw object with no pixels';
                else
                    mess_out = sprintf('Provided %s object',class(sqw_obj));
                end
                error('HORACE:PageOp_sqw_op:invalid_argument', ...
                    'sqw_op can be only applied to sqw objects which contains non-zero pixels.\n Provided: %s', ...
                    mess_out);
            end
            obj = init@PageOp_sqw_eval(obj,sqw_obj,operation,op_param,false);
            %
        end
        function obj = apply_op(obj,npix_block,npix_idx)
            % Apply user-defined operation over page of pixels located in
            % memory. Pixels have to be split on bin edges
            %
            % Inputs:
            % obj         -- initialized instance of PageOp_sqw_eval class
            % npix_block  -- array containing distrubution of pixel loaded into current page
            %                over image bins of the processed data chunk
            % npix_idx    -- 2-element array [nbin_min,nbun_max] containing
            %                min/max indices of the image bins
            %                corresponding to the pixels, currently loaded
            %                into page.
            % NOTE:
            % pixel data are split over bin edges (see split_vector_max_sum
            % for details), so npix_idx contains min/max indices of
            % currently processed image cells.
            page_data = obj.op_holder(obj, obj.op_parms{:});
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
