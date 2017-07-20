classdef IX_data_2d < IX_dataset
    % IX_data_2d class implement main operation with 2-dimensional data
    % Create IX_dataset_2d object
    %
    %   >> w = IX_dataset_2d (x,y)
    %   >> w = IX_dataset_2d (x,y,signal)
    %   >> w = IX_dataset_2d (x,y,signal,error)
    %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)
    %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis,x_distribution,y_distribution)
    %   >> w = IX_dataset_2d (title, signal, error, s_axis, x, x_axis, x_distribution, y, y_axis, y_distribution)
    %
    %  Creates an IX_dataset_2d object with the following elements:
    %
    %   title               char/cellstr    Title of dataset for plotting purposes (character array or cellstr)
    %   signal              double          Signal (2D array)
    %   error                               Standard error (2D array)
    %   s_axis              IX_axis         Signal axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x                   double          Values of bin boundaries (if histogram data)
    %                                       Values of data point positions (if point data)
    %   x_axis              IX_axis         x-axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
    %
    %   y                   double          -|
    %   y_axis              IX_axis          |- same as above but for y-axis
    %   y_distribution      logical         -|
    
    properties(Dependent)
        y
        y_axis;
        y_distribution;
        
    end
    properties(Access=protected)
        y_ = zeros(1,0);
        y_axis_ = IX_axis;
        y_distribution_ = true;
    end
    
    methods
        function obj = IX_data_2d(varargin)
            % Constructor
            if nargin==0
                return;
            end
            obj = build_IXdataset_2d_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % init object or array of objects from a structure with appropriate
        % fields
        obj = init_from_structure(obj,in); 
        %------------------------------------------------------------------        
        function yy = get.y(obj)
            if obj.valid_
                yy = obj.y_;
            else
                [ok,mess] = check_common_fields(obj);
                if ok
                    yy = obj.y_;
                else
                    yy = mess;
                end
            end
        end
        function dist = get.y_distribution(obj)
            dist = obj.y_distribution_;
        end        
        function ax = get.y_axis(obj)
            ax = obj.y_axis_;
        end        
        
    end
    %
    %----------------------------------------------------------------------
    methods(Access=protected)
        function w = binary_op_manager (w1, w2, binary_op)
            %Implement class specific binary arithmetic operations for
            % objects containing a double array.
            w = binary_op_manager_(w1, w2, binary_op);
        end
        
        function wout = binary_op_manager_single(w1,w2,binary_op)
            % Implement class specific binary operator for objects with
            % a signal and a variance array.
            wout = binary_op_manager_single_(w1,w2,binary_op);
        end
        
        function  w = unary_op_manager (w1, unary_op)
            % Implement class specific unary arithmetic operations for objects
            % containing a signal and variance arrays.
            w = unary_op_manager_(w1, unary_op);
        end
        
        function  [ok,mess] = check_common_fields(obj)
            % implement class specific check for connected fiedls
            % consistency
            [ok,mess] = check_common_fields_(obj);
        end
        function obj = check_and_set_sig_err(obj,field_name,value)
            % verify and set up signal or error arrays. Throw if
            % input can not be converted to correct array data.
            obj = check_and_set_sig_err_(obj,field_name,value);
        end
    end
    
end