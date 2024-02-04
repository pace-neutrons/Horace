classdef PageOp_sqw_eval < PageOpBase
    % Single pixel page operation used by sqw_eval function
    %
    properties
        % empty operation
        op_holder = @(h,k,l,e){};
        average = false;
        proj
        op_parms
        %
    end

    methods
        function obj = PageOp_sqw_eval(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'sqw_eval';
            obj.split_at_bin_edges = true;
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

    end
end