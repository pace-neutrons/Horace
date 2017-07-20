classdef IX_data_1d < IX_dataset
    % Create IX_dataset_1d object
    %
    %   >> w = IX_dataset_1d (x)
    %   >> w = IX_dataset_1d (x,signal)
    %   >> w = IX_dataset_1d (x,signal,error)
    %   >> w = IX_dataset_1d ([x;signal;error]) % 3xNs vector of data;
    %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
    %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
    %   >> w = IX_dataset_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
    %
    %  Creates an IX_dataset_1d object with the following elements:
    %
    % 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
    % 	signal              double  		Signal (vector)
    % 	error				        		Standard error (vector)
    % 	s_axis				IX_axis			Signal axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    % 	x					double      	Values of bin boundaries (if histogram data)
    % 						                Values of data point positions (if point data)
    % 	x_axis				IX_axis			x-axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    % 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
    
    % Default class - empty point dataset
    properties(Access=protected)
    end
    properties(Constant,Access=private)
        public_fields_list_ = ...
            {'title','signal','error','s_axis','x_axis','x','x_distribution'};
    end
    
    
    methods
        function obj=IX_data_1d(varargin)
            % Constructor
            if nargin==0
                return;
            end
            obj = build_IXdataset_1d_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % init object or array of objects from a structure with appropriate
        % fields
        obj = init_from_structure(obj,in);
        
    end
    %
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
