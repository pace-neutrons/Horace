classdef PageOp_func_eval < PageOpBase
    % Single pixel page operation used by sqw_eval function
    %

    methods
        function obj = PageOp_func_eval(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'func_eval';
            obj.split_at_bin_edges = true;            
        end
        function obj = init(obj,sqw_obj)
            obj  = init@PageOpBase(obj,sqw_obj);
            %
        end

        function obj = apply_op(obj,~,npix_idx)
            s = repelem(obj.img_.s(npix_idx(1):npix_idx(2)), obj.npix(npix_idx(1):npix_idx(2)));
            obj.page_data_(obj.signal_idx,:)   = s(:)';
            obj.page_data_(obj.var_idx,:)      = 0;
        end

        function [out_obj,obj] = finish_op(obj,out_obj)
            % transfer modifications to the underlying object
            % Image updated above
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end

    end
end