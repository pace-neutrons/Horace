classdef (Abstract=true) data_plot_interface
    % Abstract class that defines the interface to all plotting functions.
    %
    % The purpose of this interface is to assist in making a uniform
    % interface and syntax to plotting routines. It shows which methods are
    % expected for different dimensionalities of plottable objects.
    %
    % If a class inherits this interface (e.g. IX_dataset_1d) then any of
    % the methods below that are explicitly defined for that class will have
    % precedence; the other methods in this interface will throw an error to
    % that states they are undefined.
    %
    % This interface does not define the arguments needed by the plotting
    % routines. The concrete plotting implementations the use of which this
    % interface assists are methods of IX_dataset_1d, IX_dataset_2d and
    % IX_dataset_3d - see the concrete methods of those classes for 1D, 2D and
    % 3D objects respectively.
    %
    % The Horace classes d1d, d2d, d3d inherits a similar plot interface class,
    % dnd_plot_interface, which in turn inherits this class and defines
    % particular implementations of the methods. These implementations use the
    % IX_dataset_1d, *_2d and *_3d plot methods. Similarly, the Horace class sqw
    % inherits a similar plot interface class, sqw_plot_interface, which also
    % inherits data_plot_interface and defines particular implementations of the
    % plot methods as defined for d1d, d2d and d3d objects.
    
    properties
    end
    
    methods(Abstract)
        % This method is needed to enable the generic plot and plot_over methods
        % to work
        nd = dimensions();
    end
    
    %---------------------------------------------------------------------------
    % Plotting methods
    %---------------------------------------------------------------------------
    methods
        %-----------------------------------------------------------------------
        % 1D plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        function varargout = dd(w, varargin)
            % Draws a plot of markers, error bars and lines for a 1D object
            % or array of objects.
            varargout = throw_unavailable_(w, 'dd', varargin{:});
        end
        function varargout = de(w, varargin)
            % Draws a plot of error bars for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'de', varargin{:});
        end
        function varargout = dh(w, varargin)
            % Draws a histogram plot for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'dh', varargin{:});
        end
        function varargout = dl(w, varargin)
            % Draws a line plot for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'dl', varargin{:});
        end
        function varargout = dm(w, varargin)
            % Draws a marker plot for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'dm', varargin{:});
        end
        function varargout = dp(w, varargin)
            % Draws a plot of markers and error bars for a 1D object or array of
            % objects.
            varargout = throw_unavailable_(w, 'dp', varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        function varargout = pd(w, varargin)
            % Overplot markers, error bars and lines for a 1D object or array of
            % objects on an existing plot.
            varargout = throw_unavailable_(w, 'pd', varargin{:});
        end
        function varargout = pdoc(w, varargin)
            % Overplot markers, error bars and lines for a 1D object or array of
            % objects on an existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'pdoc', varargin{:});
        end
        function varargout = pe(w, varargin)
            % Overplot error bars for a 1D object or array of objects on an
            % existing plot.
            varargout = throw_unavailable_(w, 'pe', varargin{:});
        end
        function varargout = peoc(w, varargin)
            % Overplot error bars for a 1D object or array of objects on an
            % existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'peoc', varargin{:});
        end
        function varargout = ph(w, varargin)
            % Overplot histogram for a 1D object or array of objects on an
            % existing plot.
            varargout = throw_unavailable_(w, 'ph', varargin{:});
        end
        function varargout = phoc(w, varargin)
            % Overplot histogram for a 1D object or array of objects on an
            % existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'phoc', varargin{:});
        end
        function varargout = pl(w, varargin)
            % Overplot line for a 1D object or array of objects on an existing
            % plot.
            varargout = throw_unavailable_(w, 'pl', varargin{:});
        end
        function varargout = ploc(w, varargin)
            % Overplot line for a 1D object or array of objects on an existing
            % plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'ploc', varargin{:});
        end
        function varargout = pm(w, varargin)
            % Overplot markers for a 1D object or array of objects on an
            % existing plot.
            varargout = throw_unavailable_(w, 'pm', varargin{:});
        end
        function varargout = pmoc(w, varargin)
            % Overplot markers for a 1D object or array of objects on an
            % existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'pmoc', varargin{:});
        end
        function varargout = pp(w, varargin)
            % Overplot markers and error bars for a 1D object or array of
            % objects on an existing plot.
            varargout = throw_unavailable_(w, 'pp', varargin{:});
        end
        function varargout = ppoc(w, varargin)
            % Overplot markers and error bars for a 1D object or array of
            % objects on an existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'ppoc', varargin{:});
        end
        
        
        %-----------------------------------------------------------------------
        % 2D plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        function varargout = da(w, varargin)
            % Draw an area plot of a 2D dataset or array of datasets.
            varargout = throw_unavailable_(w, 'da', varargin{:});
        end
        function varargout = ds(w, varargin)
            % Draw a surface plot of a 2D dataset or array of datasets.
            varargout = throw_unavailable_(w, 'ds', varargin{:});
        end
        function varargout = ds2(w, varargin)
            % Draw a surface plot of a 2D dataset or array of datasets, with the
            % possibility of providing second dataset(s) as the source of the
            % plot or plots colour scale.
            varargout = throw_unavailable_(w, 'ds2', varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w, varargin)
            % Overplot an area plot of a 2D dataset or array of datasets.
            varargout = throw_unavailable_(w, 'pa', varargin{:});
        end
        function varargout = paoc(w, varargin)
            % Overplot an area plot of a 2D dataset or array of datasets on the
            % current figure.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'paoc', varargin{:});
        end
        function varargout = ps(w, varargin)
            % Overplot a surface plot of a 2D dataset or array of datasets
            varargout = throw_unavailable_(w, 'ps', varargin{:});
        end
        function varargout = psoc(w, varargin)
            % Overplot a surface plot of a 2D dataset or array of datasets on
            % the current figure.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'psoc', varargin{:});
        end
        function varargout = ps2(w, varargin)
            % Overplot a surface plot of a 2D dataset or array of datasets, with
            % the possibility of providing second dataset(s) as the source of
            % the plot or plots colour scale.
            varargout = throw_unavailable_(w, 'ps2', varargin{:});
        end
        function varargout = ps2oc(w, varargin)
            % Overplot a surface plot of a 2D dataset or array of datasets on
            % the current figure, with the possibility of providing second
            % dataset(s) as the source of the plot or plots colour scale.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'ps2oc', varargin{:});
        end
        
        
        %-----------------------------------------------------------------------
        % 3D plotting functions
        %-----------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots 3D object using sliceomatic.
            varargout = throw_unavailable_(w, 'sliceomatic', varargin{:});
        end
        
        function varargout = sliceomatic_overview(w, varargin)
            % Plots 3D object using sliceomatic with the view straight down one
            % of the axes.
            varargout = throw_unavailable_(w,'sliceomatic_overview', varargin{:});
        end
        
        
        %-----------------------------------------------------------------------
        % Generic plotting interfaces for N-D objects
        %-----------------------------------------------------------------------
        function varargout = plot(w,varargin)
            % Plot a 1D, 2D or 3D object or array of objects
            %
            %   >> plot(w)
            %   >> plot(w, xlo, xhi)                    % if 1D, 2D or 3D
            %   >> plot(w, xlo, xhi, ylo, yhi)          % if 2D or 3D
            %   >> plot(w, xlo, xhi, ylo, yhi, zlo,zhi) % if 3D
            %
            % Advanced use:
            %   >> plot(w,..., 'name', fig_name)        % plot with figure name = fig_name
            % or
            %   >> plot(w,..., 'axes', axes_handle)     % plot on the figure with the given
            %                                           % figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = plot(w, ...)
            %
            %
            % Equivalent to:
            %   >> dp(w)                % 1D dataset
            %   >> dp(w, ...)
            %
            %   >> da(w)                % 2D dataset
            %   >> da(w, ...)
            %
            %   >> sliceomatic(w)       % 3D dataset
            %   >> sliceomatic(w, ...)
            
            nd = w(1).dimensions();
            
            varargout = cell(1, nargout);   % output only if requested
            switch nd
                case 1
                    [varargout{:}] = dp(w, varargin{:});
                case 2
                    [varargout{:}] = da(w, varargin{:});
                case 3
                    [varargout{:}] = sliceomatic(w, varargin{:});
                otherwise
                    error('HORACE:data_plot_interface:runtime_error', ...
                        'Can only plot one, two or three-dimensional objects')
            end
        end
        
        function varargout = plotover(w,varargin)
            % Overplot a 1D, 2D or 3D object or array of objects on an existing plot
            %
            %   >> plotover(w)
            %
            % Advanced use:
            %   >> pp(w, 'name', fig_name)      % overplot on the figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pp(w,...)
            %
            %
            % Equivalent to:
            %   >> pp(w)                % 1D dataset
            %   >> pp(w,...)
            %
            %   >> pa(w)                % 2D dataset
            %   >> pa(w,...)
            
            nd = w(1).dimensions();
            
            varargout = cell(1, nargout);   % output only if requested
            switch nd
                case 1
                    [varargout{:}] = pp(w, varargin{:});
                case 2
                    [varargout{:}] = pa(w, varargin{:});
                otherwise
                    error('HORACE:data_plot_interface:runtime_error', ...
                        'Can only overplot one or two-dimensional objects')
            end
        end
    end
end


%---------------------------------------------------------------------------
% Utility functions
%---------------------------------------------------------------------------
function varargout = throw_unavailable_(obj, method, varargin)
% Throw method unavailable
varargout = cell(1, nargout);   % output only if requested
error(['HORACE:',class(obj),':invalid_argument'],...
    'Method ''%s'' is not available for objects of class ''%s''', ...
    method, class(obj))
end
