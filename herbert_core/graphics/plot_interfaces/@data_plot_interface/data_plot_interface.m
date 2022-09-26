classdef (Abstract=true) data_plot_interface
    % Class defines interface to all plotting functions available in Horace
    % for sqw and dnd objects.
    properties
    end
    methods(Abstract)
        nd = dimensions();
    end

    methods
        %------------------------------------------------------------------
        % generic plotting interfaces for N-D objects
        %------------------------------------------------------------------
        % Plot 1D, 2D or 3D sqw or dnd object or array of objects
        varargout = plot(w,varargin)
        % Overplot 1D, 2D or 3D sqw or dnd object or array of objects
        varargout = plotover(w,varargin)

        %------------------------------------------------------------------
        % 1d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function varargout = dd(w,varargin)
            % Draws a plot of markers, error bars and lines of a 1D sqw
            % or dnd object or array of objects
            varargout = throw_unavailable_( ...
                w,'dd',varargin{:});
        end
        function varargout = de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            varargout = throw_unavailable_( ...
                w,'de',varargin{:});
        end
        function varargout = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            varargout = throw_unavailable_( ...
                w,'dh',varargin{:});
        end
        function varargout = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            varargout = throw_unavailable_( ...
                w,'dl',varargin{:});
        end
        function varargout = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            varargout = throw_unavailable_( ...
                w,'dm',varargin{:});
        end
        function varargout = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            varargout = throw_unavailable_( ...
                w,'dp',varargin{:});
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            varargout = throw_unavailable_( ...
                w,'pd',varargin{:});
        end
        function varargout = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            varargout = throw_unavailable_( ...
                w,'pdoc',varargin{:});
        end
        function varargout = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            varargout = throw_unavailable_( ...
                w,'pe',varargin{:});
        end
        function varargout = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            varargout = throw_unavailable_( ...
                w,'peoc',varargin{:});
        end
        function varargout = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            varargout = throw_unavailable_( ...
                w,'ph',varargin{:});
        end
        function varargout = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            varargout = throw_unavailable_( ...
                w,'phoc',varargin{:});
        end
        function varargout = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            varargout = throw_unavailable_( ...
                w,'pl',varargin{:});
        end
        function varargout = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            varargout = throw_unavailable_( ...
                w,'ploc',varargin{:});
        end
        function varargout = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            varargout = throw_unavailable_( ...
                w,'pm',varargin{:});
        end
        function varargout = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            varargout = throw_unavailable_( ...
                w,'pmoc',varargin{:});
        end
        function varargout = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            varargout = throw_unavailable_( ...
                w,'pp',varargin{:});
        end
        function varargout = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            varargout = throw_unavailable_( ...
                w,'ppoc',varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 2d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function varargout = da(w,varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets
            varargout = throw_unavailable_( ...
                w,'da',varargin{:});
        end
        function varargout = ds(w,varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            varargout = throw_unavailable_( ...
                w,'ds',varargin{:});
        end
        function varargout = ds2(w,varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            varargout = throw_unavailable_( ...
                w,'ds2',varargin{:});
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            varargout = throw_unavailable_( ...
                w,'pa',varargin{:});
        end
        function varargout = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            varargout = throw_unavailable_( ...
                w,'paoc',varargin{:});
        end
        function varargout = ps(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            varargout = throw_unavailable_( ...
                w,'ps',varargin{:});
        end
        function varargout = ps2(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            varargout = throw_unavailable_( ...
                w,'ps2',varargin{:});
        end
        function varargout = ps2oc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            varargout = throw_unavailable_( ...
                w,'sp2oc',varargin{:});
        end
        function varargout = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets on the current figure
            varargout = throw_unavailable_( ...
                w,'psoc',varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 3d Plotting functions
        %------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic
            varargout = throw_unavailable_( ...
                w,'sliceomatic',varargin{:});
        end
        function varargout = sliceomatic_overview(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic with view straight down one of the axes
            varargout = throw_unavailable_( ...
                w,'sliceomatic_overview',varargin{:});
        end
    end
end