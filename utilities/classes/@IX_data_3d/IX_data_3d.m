classdef IX_data_3d < IX_dataset
    % Create IX_data_3d object
    %
    %   >> w = IX_data_3d (x,y,z)
    %   >> w = IX_data_3d (x,y,z,signal)
    %   >> w = IX_data_3d (x,y,z,signal,error)
    %   >> w = IX_data_2d (x,y,z,signal,error, x_distribution,y_distribution,z_distribution)    
    %   >> w = IX_data_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
    %   >> w = IX_data_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
    %   >> w = IX_data_3d (title, signal, error, s_axis, x, x_axis, x_distribution,...
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
        % x - vector of bin boundaries for histogram data or bin centers
        % for distribution
        x
        % x_axis -- IX_axis class containing x-axis caption
        x_axis;
        % x_distribution -- an identifier, stating if the x-data contain
        % points or distribution in x-direction
        x_distribution;
        % y - vector of bin boundaries for histogram data or bin centers
        % for distribution in y-direction
        y
        % y_axis -- IX_axis class containing y-axis caption
        y_axis;
        % y_distribution -- an identifier, stating if the y-data contain
        % points or distribution in y-direction
        y_distribution;
        % z - vector of bin boundaries for histogram data or bin centers
        % for distribution in z-direction
        z
        % z_axis -- IX_axis class containing z-axis caption
        z_axis;
        % z_distribution -- an identifier, stating if the z-data contain
        % points or distribution in z-direction
        z_distribution;
    end
    properties(Access=protected)
    end
    %======================================================================
    methods(Static)
        function nd  = ndim()
            %return the number of class dimensions
            nd = 3;
        end
    end
    %======================================================================
    methods
        function obj = IX_data_3d(varargin)
            % constructor
            obj.xyz_ = cell(3,1);
            obj.xyz_axis_ = repmat(IX_axis(),3,1);
            obj.xyz_distribution_ = true(3,1);
            
            if nargin==0
                obj.signal_ = zeros(0,0,0);
                obj.error_ = zeros(0,0,0);
                obj.xyz_{1} = zeros(1,0);
                obj.xyz_{2} = zeros(1,0);
                obj.xyz_{3} = zeros(1,0);
                return;
            end
            obj = build_IXdataset_3d_(obj,varargin{:});
        end
        function obj = init(obj,varargin)
            % efficiently (re)initialize object using constructor's code
            obj = build_IXdataset_3d_(obj,varargin{:});
        end
        
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % Get information for one or more axes and if is histogram data for each axis
        [ax,hist]=axis(w,n)
        
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function xx = get.x(obj)
            xx = obj.get_xyz_data(1);
        end
        function ax = get.x_axis(obj)
            ax = obj.xyz_axis_(1);
        end
        function dist = get.x_distribution(obj)
            dist = obj.xyz_distribution_(1);
        end
        %
        function obj = set.x(obj,val)
            obj = set_xyz_data(obj,1,val);
        end
        function obj = set.x_axis(obj,val)
            obj.xyz_axis_(1) = obj.check_and_build_axis(val);
        end
        function obj = set.x_distribution(obj,val)
            % TODO: should setting it to true/false involve chaning x from
            % disrtibution to bin centers and v.v.?
            obj.xyz_distribution_(1) = logical(val);
        end
        %-----------------------------------------------------------------
        function yy = get.y(obj)
            yy = obj.get_xyz_data(2);
        end
        %
        function dist = get.y_distribution(obj)
            dist = obj.xyz_distribution_(2);
        end
        function ax = get.y_axis(obj)
            ax = obj.xyz_axis_(2);
        end
        %
        function obj = set.y(obj,val)
            obj = set_xyz_data(obj,2,val);
        end
        function obj = set.y_distribution(obj,val)
            % TODO: should setting it to true/false involve chaning y from
            % disrtibution to bin centers and v.v.? + signal changes
            obj.xyz_distribution_(2) = logical(val);
        end
        function obj = set.y_axis(obj,val)
            obj.xyz_axis_(2) = obj.check_and_build_axis(val);
        end
        %-----------------------------------------------------------------
        function zz = get.z(obj)
            zz= obj.get_xyz_data(3);
        end
        %
        function dist = get.z_distribution(obj)
            dist = obj.xyz_distribution_(3);
        end
        function ax = get.z_axis(obj)
            ax = obj.xyz_axis_(3);
        end
        %
        function obj = set.z(obj,val)
            obj = set_xyz_data(obj,3,val);
        end
        function obj = set.z_distribution(obj,val)
            % TODO: should setting it to true/false involve chaning y from
            % disrtibution to bin centers and v.v.? + signal changes
            obj.xyz_distribution_(3) = logical(val);
        end
        function obj = set.z_axis(obj,val)
            obj.xyz_axis_(3) = obj.check_and_build_axis(val);
        end
    end
    %======================================================================
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
    %======================================================================
    methods(Static,Access = protected)
        
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax,x, s, e, xout, use_mex, force_mex)
        %Integrates point data along along specific axis.
        [wout_s,wout_e] = integrate_points(iax,x, s, e, xout, use_mex, force_mex)
    end
    
end