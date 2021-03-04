classdef (Abstract) SQWDnDBase
    %SQWDnDBase Abstract SQW/DnD object base class
    %   Abstract class defining common API and atrributes of the SQW and
    %   DnD objects

    properties (Abstract) % Public
      %  abstract_prop
    end

    properties (Access = protected)
        % base_property
        data_;
    end

    methods (Abstract, Access = protected)
        wout = unary_op_manager(w, operation_handle);
        wout = binary_op_manager_single(w1,w2,binary_op);
    end

    methods  % Public
        [ok,mess,nd_ref]=dimensions_match(w,nd_ref);
        wout = IX_dataset_1d (w);
        wout = IX_dataset_2d (w);
        wout = IX_dataset_3d (w);
        [xout,yout,sout,eout,nout]=convert_bins_for_shoelace(win,wref);
    end

    methods (Access = protected)
        wout = binary_op_manager(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);
    end
end

