classdef PageOp_sqw_eval < PageOpBase
    % Single pixel page operation used by sqw_eval algorithm
    %
    properties
        % empty operation
        op_holder = @(h,k,l,e){};
        average = false;
        proj        % the projection used for transforming
        op_parms
        sigvar_idx % page indices (numbers of rows) for signal and variance
        %             values within single data page
    end
    properties(Access = protected)
        % caches for split indices of npix array, produced by
        % split_indices routines and defined here to access it
        % from npix_data which does not have it as a standard input        
        npix_block_;
        npix_idx_;
    end

    properties(Dependent)
        npix_block; % read only access to


        %Read-only Access to internal image holder to use in sqw_op
        img
            % npix_idx    -- 2-element array [nbin_min,nbin_max] containing
            %                min/max indices of the image bins
            %                corresponding to the pixels, currently loaded
            %                into page.
        
        npix_idx;   %        
    end


    methods
        function obj = PageOp_sqw_eval(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'sqw_eval';
            obj.split_at_bin_edges = true;
            obj.sigvar_idx = PixelDataBase.field_index('sig_var');
        end
        function obj = init(obj,sqw_obj,operation,op_param,average)
            obj           = init@PageOpBase(obj,sqw_obj);
            obj.average   = average;
            obj.op_holder = operation;
            obj.op_parms  = op_param;
            %--------------------------------------------------------------
            obj.split_at_bin_edges = obj.average;
            %--------------------------------------------------------------
            %
            if isa(sqw_obj,'sqw') % non-sqw impossible for sqw_eval but may
                % be necessary for children (generic apply)
                obj.proj      = sqw_obj.data.proj;
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
            % Apply user-defined operation over page of pixels located in
            % memory. Pixels have to be split on bin edges
            %
            % Inputs:
            % obj         -- initialized instance of PageOp_sqw_eval class
            % npix_block  -- array containing distrubution of pixel loaded into current page
            %                over image bins of the processed data chunk
            % npix_idx    -- 2-element array [nbin_min,nbin_max] containing
            %                min/max indices of the image bins
            %                corresponding to the pixels, currently loaded
            %                into page.
            % NOTE:
            % pixel data are split over bin edges (see split_vector_max_sum
            % for details), so npix_idx contains min/max indices of
            % currently processed image cells.
            %
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
            obj.var_acc_ = zeros(numel(obj.sig_acc_),1); % I do not like this but this is legacy behaviour

            % transfer modifications to the underlying object
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end
        % Getters for read-only properties
        function im = get.img(obj)
            im = obj.img_;
        end
        function npb = get.npix_idx(obj)
            npb = obj.npix_idx_;
        end
        function npb = get.npix_block(obj)
            npb = obj.npix_block_;
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
