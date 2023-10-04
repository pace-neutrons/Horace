classdef PageOp_sqw_eval < PageOpBase
    % Single pixel page operation used by sqw_eval function
    %
    properties
        % empty operation
        op_holder = @(h,k,l,e){};
        average
        proj
        op_parms
        %
    end

    methods
        function [obj,sqw_obj] = init(obj,sqw_obj,operation,op_param,average)
            [obj,sqw_obj] = init@PageOpBase(obj,sqw_obj);
            obj.proj      = sqw_obj.data.proj;
            obj.average   = average;
            obj.op_holder = operation;
            obj.op_parms  = op_param;
            %
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            obj.page_data_ = obj.pix_.data;

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
            obj.page_data_(obj.var_idx,:)      = zeros(1, numel(new_signal));

            img_signal = compute_bin_data(npix_block,new_signal,[],true);
            obj.sig_acc_(npix_idx(1):npix_idx(2)) = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2))+img_signal(:);
        end

        function [out_obj,obj] = finish_op(obj,out_obj)
            % Complete image modifications:
            sz = size(obj.img_.s);
            calc_sig = obj.sig_acc_(:)./obj.npix_(:);
            nopix = obj.npix_ == 0;
            calc_sig(nopix) = 0;
            obj.img_.s    = reshape(calc_sig,sz);
            obj.img_.e    = zeros(size(obj.img_.s)); % I do not like this but this is legacy behaviour
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end

    end
end