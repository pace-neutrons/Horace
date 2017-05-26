classdef IX_dataset
    % Parent class for IXDatasets_nd;
    
    properties(Access=protected)
        title_={};
        signal_=zeros(0,1);
        error_=zeros(0,1);
        s_axis_=IX_axis;
        x_=zeros(1,0);
        x_axis_=IX_axis;
        x_distribution_=true;
        valid_ = true;        
    end
    
    methods(Abstract,Access=protected)
        %Implement binary arithmetic operations for objects containing a double array.
        w = binary_op_manager (w1, w2, binary_op)
        % Implement binary operator for objects with a signal and a variance array.
        wout = binary_op_manager_single(w1,w2,binary_op)
        % Implement unary arithmetic operations for objects containing a signal and variance arrays.
        w = unary_op_manager (w1, unary_op)
    end
    
end

