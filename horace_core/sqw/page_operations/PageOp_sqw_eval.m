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

        function [obj,page_data] = apply_op(obj,npix_block,npix_idx,pix_idx1,pix_idx2)
            single_page = nargin == 2;
            if single_page
                page_data = obj.pix_.data;
            else
                page_data = obj.pix_.get_pixels(pix_idx1:pix_idx2,'-raw');
            end
            qw = obj.proj.transform_pix_to_hkl(page_data(obj.coord_idx,:));
            qw_pix_coord =  {qw(1,:)',qw(2,:)',qw(3,:)',qw(4,:)'};
            if obj.average
                % Get average h, k, l, e for the bin, compute sqw for that average,
                % and fill pixels with the average signal for the bin that contains
                % them
                qw_ave =average_bin_data(npix_block,qw_pix_coord);
                qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
                new_signal = obj.op_holder(qw_ave{:}, obj.op_parms{:});
                new_signal = repelem(new_signal, npix_block(:));
            else
                new_signal = obj.op_holder(qw_pix_coord{:}, obj.op_parms{:});
            end
            page_data(obj.signal_idx,:)   = new_signal(:)';
            page_data(obj.var_idx,:)      = zeros(1, numel(new_signal));
            if single_page
                obj.img_.s     = compute_bin_data(npix_block,new_signal);
                obj.pix_       = obj.pix_.set_raw_data(page_data);
            else
                obj.img_.s(npix_idx(1):npix_idx(2)) = ...
                    compute_bin_data(npix_block,new_signal);
            end
        end
        function [out_obj,obj] = finish_op(obj,out_obj)
            %
            obj.img_.e    = zeros(size(obj.img_.s));
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end

    end
end