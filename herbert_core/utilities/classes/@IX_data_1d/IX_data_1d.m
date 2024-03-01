classdef IX_data_1d < IX_dataset
    % IX_data_1d class implements main operation with 1-dimensional data
    %
    % Constructor to create IX_dataset_1d object:
    %
    %   >> w = IX_data_1d (x)
    %   >> w = IX_data_1d (x,signal)
    %   >> w = IX_data_1d (x,signal,error)
    %   >> w = IX_data_1d ([x;signal;error]) % 3xNs vector of data;
    %   >> w = IX_data_1d (x,signal,error, x_distribution)
    %   >> w = IX_data_1d (x,signal,error,title,x_axis,s_axis)
    %   >> w = IX_data_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
    %   >> w = IX_data_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
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
    %
    %
    properties(Dependent)
        % x - vector of bin boundaries for histogram data or bin centers
        % for distribution
        x
        % x_axis -- IX_axis class containing x-axis caption
        x_axis;
        % x_distribution -- an identifier, stating if the x-data contain
        % points or distribution in x-direction
        x_distribution;
    end
    %======================================================================
    methods(Static)
        function nd  = ndim()
            %return the number of class dimensions
            nd = 1;
        end
    end
    %======================================================================
    methods
        function obj=IX_data_1d(varargin)
            % Constructor
            obj.xyz_      = cell(1,1);
            obj.xyz_axis_ = IX_axis();
            obj.xyz_distribution_ = true;
            if nargin==0
                obj.xyz_{1} = zeros(1,0);
                return;
            end
            obj = build_IXdataset_1d_(obj,varargin{:});
        end
        function obj = init(obj,varargin)
            % efficiently (re)initialize object using constructor's code
            obj = build_IXdataset_1d_(obj,varargin{:});
        end
        %------------------------------------------------------------------
        function xx = get.x(obj)
            xx = obj.get_xyz_data(1);
        end

        function ax = get.x_axis(obj)
            ax = obj.xyz_axis_(1);
        end
        function dist = get.x_distribution(obj)
            dist = obj.xyz_distribution_(1);
            %dist = numel(obj.signal_) == numel(obj.xyz_{1});
        end
        %
        function obj = set.x(obj,val)
            obj = set_xyz_data(obj,1,val);
            if obj.do_check_combo_arg
                obj = check_combo_arg (obj);
            end
        end
        function obj = set.x_axis(obj,val)
            obj.xyz_axis_(1) = obj.check_and_build_axis(val);
        end
        function obj = set.x_distribution(obj,val)
            % TODO: should setting it to true/false involve changing x from
            % distribution to bin centres and v.v.?
            obj.xyz_distribution_(1) = logical(val);
        end
        function [frac,n_points] = calc_continuous_fraction(obj)
            % Calculate the fraction of continuous areas of plot
            % not containing NaNs, so to be displayed on a plot.
            % e.g:
            % if signal = [1,NaN,2,3,NaN,4] the continuous plot area would
            % be 2,3, and points 1 and 4 are not displaying if you are
            % plotting a line. Such dataset contains 4 points, only two
            % would be plotted by pl, so the function returns frac = 2/4 = 0.5;
            % If more than one plot is passed in obj as an array, then the
            % minimum frac value over all plots and the corresponding point
            % number is returned.
            %
            % Up to 2 dimensions of plots are supported but higher numbers
            % will error.
            %
            % Returns:
            % frac  -- fraction of the points to be plotted out of all
            % n_points -- number of points containing information (not NaN-s)
            %

            nd = ndims(obj);
            if nd>2
                error('HERBERT:IX_data_1d:calc_continuous_fraction', ...
                    ['array of IX_data_1d has more than 2 dimensions, ' ...
                    'and cannot be used with calc_continuous_fraction']);
            end
            [fr,np] = arrayfun(@calc_cont_frac_, obj);
            [frac, ind] = min(fr);
            n_points = np(ind);
        end
    end
    %======================================================================
    methods(Access=protected)
        function obj = check_and_set_sig_err(obj,field_name,value)
            % verify and set up signal or error arrays. Throw if
            % input can not be converted to correct array data.
            obj = check_and_set_sig_err_(obj,field_name,value);
        end
    end
    %======================================================================
    methods(Static,Access = protected)
        % Rebins histogram data along specific axis.
        [wout_s, wout_e] = rebin_hist(iax, x, s, e, xout)
        %Integrates point data along along specific axis.
        [wout_s,wout_e] = integrate_points(iax, x, s, e, xout)
    end
    %======================================================================
    methods
        function obj = check_combo_arg (obj)
            % Check validity of interdependent properties
            [ok,mess] = check_joint_fields_(obj);
            if ~ok
                error('HERBERT:IX_data_1d:invalid_argument',mess)
            end
        end
        function flds = saveableFields(obj)
            base = saveableFields@IX_dataset(obj);
            flds = [base(:);'x';'x_distribution';'x_axis'];
        end

    end
    methods(Static)
        function obj = loadobj(S)
            % function to support loading of outdated versions of the class
            % from mat files on hdd
            obj = IX_data_1d();
            obj = loadobj@serializable(S,obj);
        end
    end

end

