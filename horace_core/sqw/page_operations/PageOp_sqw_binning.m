classdef PageOp_sqw_binning < PageOp_sqw_eval
    % Single pixel page operation used by sqw_op algorithm
    %
    properties
        new_binning;
        new_range;
        %
    end
    properties(Access=protected)
        npix_acc_
        pix_page_;
    end

    methods
        function obj = PageOp_sqw_binning(varargin)
            obj = obj@PageOp_sqw_eval(varargin{:});
            obj.op_name_ = 'sqw_binning';
        end
        function obj = init(obj,sqw_obj,operation,op_param,pop_options)
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
            % Returns:
            % obj      --  PageOp_sqw_op instance initialized to run
            %              operation over it
            %
            obj = init@PageOp_sqw_eval(obj,sqw_obj,operation,op_param,false);
            obj.img_.do_check_combo_arg = false;
            obj.img_.axes.img_range = obj.new_range;
            obj.img_.axes.nbins_all_dims = obj.new_binning;

            obj.split_at_bin_edges = true;
            obj.do_nopix = pop_options.nopix;

            obj.sig_acc_  = zeros(obj.new_binning);
            obj.var_acc_  = zeros(obj.new_binning);
            obj.npix_acc_ = zeros(obj.new_binning);
            obj.pix_page_ = PixelDataMemory();
        end
        function obj = apply_op(obj,varargin)
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
            if isempty(page_data)
                return;
            end
            pix = obj.pix_page_;
            pix = pix.set_raw_data(page_data);
            [obj.npix_acc_,obj.sig_acc_,obj.var_acc_] = obj.proj.bin_pixels(...
                obj.img_.axes,pix, ...
                obj.npix_acc_,obj.sig_acc_,obj.var_acc_);
        end
        %
        %
        function [out_obj,obj] = finish_op(obj,out_obj)
            % Overload finish op to do operations, specific to pixels
            % binning
            %
            % transfer modifications to the underlying object.
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_,obj.npix_acc_);
            %
            [out_obj,obj] = obj.finish_core_op(out_obj);
        end
        %------------------------------------------------------------------
    end
end
