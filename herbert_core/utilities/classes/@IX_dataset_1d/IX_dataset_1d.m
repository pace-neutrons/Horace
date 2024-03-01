classdef IX_dataset_1d < IX_data_1d & data_plot_interface
    % Class adds operations with graphics to main operations with 1-d data
    %
    % See IX_data_1d for main properties and constructors, used to operate
    % with 1d data
    %
    % Common way to create IX_dataset_1d object:
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
    %   title           char/cellstr    Title of dataset for plotting purposes (character array or cellstr)
    %   signal          double          Signal (vector)
    %   error                               Standard error (vector)
    %   s_axis          IX_axis         Signal axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x                   double          Values of bin boundaries (if histogram data)
    %                                       Values of data point positions (if point data)
    %   x_axis          IX_axis         x-axis object containing caption and units codes
    %                   (or char/cellstr    Can also just give caption; multiline input in the form of a
    %                                      cell array or a character array)
    %   x_distribution  logical         Distribution data flag (true is a distribution; false otherwise)
    %
    %
    methods(Static)
        function obj = loadobj(S)
            % function to support loading of modern and outdated versions
            % of the class from mat files on hdd
            obj = IX_dataset_1d();
            obj = loadobj@serializable(S,obj);

        end
    end
    methods
        %------------------------------------------------------------------
        function obj= IX_dataset_1d(varargin)
            obj = obj@IX_data_1d(varargin{:});
        end
        %------------------------------------------------------------------
        % actual plotting interface:
        %------------------------------------------------------------------
        % PLOT:
        [figureHandle, axesHandle, plotHandle] = dd(w,varargin);
        [figureHandle, axesHandle, plotHandle] = de(w,varargin);
        [figureHandle, axesHandle, plotHandle] = dh(w,varargin);
        [figureHandle, axesHandle, plotHandle] = dl(w,varargin);
        [figureHandle, axesHandle, plotHandle] = dm(w,varargin);
        [figureHandle, axesHandle, plotHandle] = dp(w,varargin);
        %------------------------------------------------------------------
        % OVERPLOT
        [figureHandle, axesHandle, plotHandle] = pd(w,varargin);
        [figureHandle, axesHandle, plotHandle] = pdoc(w,varargin);
        [figureHandle, axesHandle, plotHandle] = pe(w,varargin);
        [figureHandle, axesHandle, plotHandle] = peoc(w,varargin);
        [figureHandle, axesHandle, plotHandle] = ph(w,varargin);
        [figureHandle, axesHandle, plotHandle] = phoc(w,varargin);
        [figureHandle, axesHandle, plotHandle] = pl(w,varargin);
        [figureHandle, axesHandle, plotHandle] = ploc(w,varargin);
        [figureHandle, axesHandle, plotHandle] = pm(w,varargin);
        [figureHandle, axesHandle, plotHandle] = pmoc(w,varargin);
        [figureHandle, axesHandle, plotHandle] = pp(w,varargin);
        [figureHandle, axesHandle, plotHandle] = ppoc(w,varargin);
        %------------------------------------------------------------------
    end
end

