classdef PageOp_sqw_op < PageOp_sqw_eval
    % Single pixel page operation used by sqw_op algorithm
    %

    methods
        function obj = PageOp_sqw_op(varargin)
            obj = obj@PageOp_sqw_eval(varargin{:});
            obj.op_name_ = 'sqw_op';
        end
        function obj = init(obj,sqw_obj,operation,op_param,op_options)
            % Initialize PageOp_sqw_op operation over input sqw file
            %
            % Inputs:
            % obj       -- instance of PageOp_sqw_op class
            % sqw_obj   -- intance of sqw object to perform operation on
            % operation -- function handle to the function constructed according
            %              to sqw_op function rules, which would perform
            %              the operation
            % op_param  -- cellarray of operation parameters to be provided
            %              to operation in the form:
            %              operation(obj,op_param{:});
            % op_options-- the structure, which provides information about 
            %              fine-tunning of PageOP operation
            % fields currently used:
            % .nopix    -- if true, return only dnd object build on the
            %              basis of modified pixels data.
            % 
            % Returns:
            % obj      --  PageOp_sqw_op instance initialized to run
            %              operation over it
            %
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
            obj.var_acc_ = zeros(numel(obj.npix),1);
            % pages should be split on bin edges. Most generic case
            obj.split_at_bin_edges = true;
            obj.do_nopix = op_options.nopix;

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
            % Returns:
            % obj         -- modified object with pixels page currently in
            %                memory being modified by user operation and
            %                image accumulators (signal and variane for
            %                image being updated with modifies pixels
            %                signal and error.
            %
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
        %
        function obj = update_img_accumulators(obj,npix_block,npix_idx, ...
                new_signal,variance)
            % Re-overload (return to basics) to override sqw_eval.
            % Variance accumulator may be requested by user for this poration
            % so we enable it back unlike sqw_eval, which has it equal to 0
            obj = update_img_accumulators@PageOpBase(obj,npix_block,npix_idx, ...
                new_signal,variance);
        end
        %
        function [out_obj,obj] = finish_op(obj,out_obj)
            % Re-overload (return to basics) to override sqw_eval.
            % transfer modifications to the underlying object. Return to
            % generic behaviour
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end
    end
end
