classdef IX_data_3d < IX_dataset
    % Create IX_dataset_3d object
    %
    %   >> w = IX_dataset_3d (x,y,z)
    %   >> w = IX_dataset_3d (x,y,z,signal)
    %   >> w = IX_dataset_3d (x,y,z,signal,error)
    %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
    %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
    %   >> w = IX_dataset_3d (title, signal, error, s_axis, x, x_axis, x_distribution,...
    %                                          y, y_axis, y_distribution, z, z-axis, z_distribution)
    %
    %  Creates an IX_dataset_3d object with the following elements:
    %
    % 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
    % 	signal              double  		Signal (3D array)
    % 	error				        		Standard error (3D array)
    % 	s_axis				IX_axis			Signal axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    % 	x					double      	Values of bin boundaries (if histogram data)
    % 						                Values of data point positions (if point data)
    % 	x_axis				IX_axis			x-axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    % 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
    %
    %   y                   double          -|
    %   y_axis              IX_axis          |- same as above but for y-axis
    %   y_distribution      logical         -|
    %
    %   z                   double          -|
    %   z_axis              IX_axis          |- same as above but for z-axis
    %   z_distribution      logical         -|
    properties(Dependent)
        y
        y_axis;
        y_distribution;
        z
        z_axis;
        z_distribution;
    end
    properties(Access=protected)
        y_ = zeros(1,0);
        y_axis_ = IX_axis;
        y_distribution_ = true;
        z_ = zeros(1,0);
        z_axis_ = IX_axis;
        z_distribution_ = true;
    end
    
    methods
        function obj = IX_data_3d(varargin)
            % constructor
            if nargin==0
                return;
            end
            obj = build_IXdataset_3d_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % Get information for one or more axes and if is histogram data for each axis
        [ax,hist]=axis(w,n)
        
        %------------------------------------------------------------------
        function yy = get.y(obj)
            if obj.valid_
                yy = obj.y_;
            else
                [ok,mess] = check_joint_fields(obj);
                if ok
                    yy = obj.y_;
                else
                    yy = mess;
                end
            end
        end
        %
        function dist = get.y_distribution(obj)
            dist = obj.y_distribution_;
        end
        function ax = get.y_axis(obj)
            ax = obj.y_axis_;
        end
        %
        function obj = set.y(obj,val)
            obj.y_ = obj.check_xyz(val);
            ok = check_joint_fields(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        function obj = set.y_distribution(obj,val)
            % TODO: should setting it to true/false involve chaning y from
            % disrtibution to bin centers and v.v.? + signal changes
            obj.y_distribution_ = logical(val);
        end
        function obj = set.y_axis(obj,val)
            obj.y_axis_ = obj.check_and_build_axis(val);
        end
        %-----------------------------------------------------------------
        function zz = get.z(obj)
            if obj.valid_
                zz = obj.z_;
            else
                [ok,mess] = check_joint_fields(obj);
                if ok
                    zz = obj.z_;
                else
                    zz = mess;
                end
            end
        end
        %
        function dist = get.z_distribution(obj)
            dist = obj.z_distribution_;
        end
        function ax = get.z_axis(obj)
            ax = obj.z_axis_;
        end
        %
        function obj = set.z(obj,val)
            obj.z_ = obj.check_xyz(val);
            ok = check_joint_fields(obj);
            if ok
                obj.valid_ = true;
            else
                obj.valid_ = false;
            end
        end
        function obj = set.z_distribution(obj,val)
            % TODO: should setting it to true/false involve chaning y from
            % disrtibution to bin centers and v.v.? + signal changes
            obj.z_distribution_ = logical(val);
        end
        function obj = set.z_axis(obj,val)
            obj.z_axis_ = obj.check_and_build_axis(val);
        end
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        function  [ok,mess] = check_joint_fields(obj)
            % implement class specific check for connected fiedls
            % consistency
            [ok,mess] = check_joint_fields_(obj);
        end
        function obj = check_and_set_sig_err(obj,field_name,value)
            % verify and set up signal or error arrays. Throw if
            % input can not be converted to correct array data.
            obj = check_and_set_sig_err_(obj,field_name,value);
        end
    end
end