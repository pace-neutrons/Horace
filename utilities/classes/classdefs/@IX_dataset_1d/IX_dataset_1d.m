classdef IX_dataset_1d < IX_graphics_1d
    % Create IX_dataset_1d object
    %
    %   >> w = IX_dataset_1d (x)
    %   >> w = IX_dataset_1d (x,signal)
    %   >> w = IX_dataset_1d (x,signal,error)
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
    properties(Dependent)
        title;
        signal
        error
        s_axis
        x
        x_axis;
        x_distribution;
        
    end
    properties(Access=protected)
    end
    properties(Constant,Access=private)
        public_fields_list_ = ...
            {'title','signal','error','s_axis','x_axis','x','x_distribution'};
    end
    
    methods
        function obj=IX_dataset_1d(varargin)
            % Constructor
            if nargin==0
                return;
            end
            obj = build_IXdataset_1d_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function tit = get.title(obj)
            tit = obj.title_;
        end
        %
        function xx = get.x(obj)
            if obj.valid_
                xx = obj.x_;
            else
                [ok,mess] = check_common_fields_(obj);
                if ok
                    xx = obj.x_;
                else
                    xx = mess;
                end
            end
        end
        
        function sig = get.signal(obj)
            if obj.valid_
                sig = obj.signal_;
            else
                [ok,mess] = check_common_fields_(obj);
                if ok
                    sig = obj.signal_;
                else
                    sig = mess;
                end
            end
        end
        %
        function err = get.error(obj)
            if obj.valid_
                err = obj.error_;
            else
                [ok,mess] = check_common_fields_(obj);
                if ok
                    err = obj.error_;
                else
                    err = mess;
                end
            end
        end
        %------------------------------------------------------------------
        function ax = get.x_axis(obj)
            ax = obj.x_axis_;
        end
        function ax = get.s_axis(obj)
            ax = obj.s_axis_;
        end
        function dist = get.x_distribution(obj)
            dist = obj.x_distribution_;
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function obj = set.title(obj,val)
            obj = check_and_set_title_(obj,val);
        end
        function obj = set.x_axis(obj,val)
            obj = check_and_set_axis_(obj,'x_axis',val);
        end
        function obj = set.s_axis(obj,val)
            obj = check_and_set_axis_(obj,'s_axis',val);
        end
        %
        function obj = set.x_distribution(obj,val)
            obj.x_distribution_ = logical(val);
        end
        %------------------------------------------------------------------
        function obj = set.x(obj,val)
            obj = check_and_set_x_(obj,val);
            ok = check_common_fields_(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        function obj = set.signal(obj,val)
            obj = check_and_set_sig_err_(obj,'signal',val);
            ok = check_common_fields_(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        function obj = set.error(obj,val)
            obj = check_and_set_sig_err_(obj,'error',val);
            ok = check_common_fields_(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        %------------------------------------------------------------------
        % method checks if common fiedls are consistent between each
        % other. Call this method from a program after changing
        % x,signal, error using set operations
        [obj,mess] = isvalid(obj)
        
        function ok = get_isvalid(obj)
            % returns the state of the internal valid_ property
            ok = obj.valid_;
        end
    end
    %
    methods(Access=protected)
        function w = binary_op_manager (w1, w2, binary_op)
            %Implement binary arithmetic operations for objects containing a double array.
            w = binary_op_manager_(w1, w2, binary_op);
        end
        
        function wout = binary_op_manager_single(w1,w2,binary_op)
            % Implement binary operator for objects with a signal and a variance array.
            wout = binary_op_manager_single_(w1,w2,binary_op);
        end
        
        function  w = unary_op_manager (w1, unary_op)
            % Implement unary arithmetic operations for objects containing a signal and variance arrays.
            w = unary_op_manager_(w1, unary_op);
        end
    end
    
    
end
