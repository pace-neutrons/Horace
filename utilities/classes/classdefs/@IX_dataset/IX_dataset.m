classdef IX_dataset
    % Abstract parent class for IX_datasets_Nd;
    properties(Dependent)
        %title:  dataset title (will be plotted on a grapth)
        title;
        % signal -- array of signal...
        signal
        % error  -- array of errors
        error
        % s_axis -- IX_axis class containing signal axis caption
        s_axis
        % x - vector of bin boundaries for histogram data or bin centers
        % for distribution
        x
        % x_axis -- IX_axis class containing x-axis caption
        x_axis;
        % x_distribution -- a
        x_distribution;
    end
    
    
    properties(Access=protected)
        title_={};
        % emtpy signal
        signal_=zeros(0,1);
        % empty error
        error_=zeros(0,1);
        % has empty signals-IX_axis
        s_axis_=IX_axis('Conunts');
        % empty x binning data;
        x_=zeros(1,0);
        % has empty x-IX_axis
        x_axis_=IX_axis;
        % assume to be not a distribution,as size(x_) == size(s_);
        x_distribution_=false;
        % empty object it valid
        valid_ = true;
    end
    methods
        %------------------------------------------------------------------
        % Methors, accessed using unary/binary operation manager are stored
        % in the class folder only. Their signatures are not presented
        % here.
        %------------------------------------------------------------------
        % Signatures for common methods, which do not use unary/binary
        % operation manager:
        %------------------------------------------------------------------
        % method checks if common fiedls are consistent between each
        % other. Call this method from a program after changing
        % x,signal, error using set operations. Throws 'invalid_argument'
        % if class is incorrent and and the method is called with one
        % output argument. Returns error message, if class is incorrect and
        % method called with two output arguments.
        [obj,mess] = isvalid(obj)
        % Get information for one or more axes and if is histogram data for each axis
        [ax,hist]=axis(w,n)
        
        %------------------------------------------------------------------
        % Access Properties:
        %------------------------------------------------------------------
        function tit = get.title(obj)
            tit = obj.title_;
        end
        %
        function xx = get.x(obj)
            if obj.valid_
                xx = obj.x_;
            else
                [ok,mess] = check_common_fields(obj);
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
                [ok,mess] = check_common_fields(obj);
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
                [ok,mess] = check_common_fields(obj);
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
            % TODO: should setting it to true/false involve chaning x from
            % disrtibution to bin centers and v.v.?
            obj.x_distribution_ = logical(val);
        end
        %------------------------------------------------------------------
        function obj = set.x(obj,val)
            obj = check_and_set_x_(obj,val);
            ok = check_common_fields(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        function obj = set.signal(obj,val)
            obj = check_and_set_sig_err(obj,'signal',val);
            ok = check_common_fields(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        function obj = set.error(obj,val)
            obj = check_and_set_sig_err(obj,'error',val);
            ok = check_common_fields(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        %--------------------------------------------------------------
        function ok = get_isvalid(obj)
            % returns the state of the internal valid_ property
            ok = obj.valid_;
        end
        %
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    methods(Abstract,Static)
        % used to reload old style objects from mat files on hdd
        obj = loadobj(data)
    end
    
    methods(Abstract,Access=public)
        % method necessary for loadobj to work in order to support the reloading
        % of old style classes from mat files.
        obj = init_from_structure(obj,struct)
    end
    
    methods(Abstract,Access=protected)
        %Implement binary arithmetic operations for objects containing a double array.
        w = binary_op_manager (w1, w2, binary_op)
        % Implement binary operator for objects with a signal and a variance array.
        wout = binary_op_manager_single(w1,w2,binary_op)
        % Implement unary arithmetic operations for objects containing a signal and variance arrays.
        w = unary_op_manager (w1, unary_op)
        %------------------------------------------------------------------
        % Generic checks:
        % Check if various interdependent fields of a class are consistent
        % between each other.
        [ok,mess] = check_common_fields(obj);
        % verify and set signal or error arrays
        obj = check_and_set_sig_err(obj,field_name,value);
        %
    end
    
end

