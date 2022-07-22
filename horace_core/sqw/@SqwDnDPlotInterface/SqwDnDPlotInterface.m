classdef SqwDnDPlotInterface
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
        [figureHandle, axesHandle, plotHandle] = plot(w,varargin)        
        % Overplot 1D, 2D or 3D sqw or dnd object or array of objects        
        [figureHandle, axesHandle, plotHandle] = plotover(w,varargin)

        %------------------------------------------------------------------        
        % 1d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function [figureHandle, axesHandle, plotHandle] = dd(w,varargin)
            % Draws a plot of markers, error bars and lines of a 1D sqw 
            % or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'dd',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'de',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'dh',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'dl',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'dm',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'dp',varargin{:});
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function [figureHandle, axesHandle, plotHandle] = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pd',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pdoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pe',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'peoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'ph',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'phoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pl',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'ploc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pm',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pmoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pp',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'ppoc',varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 2d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function [figureHandle, axesHandle, plotHandle] = da(w,varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'da',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ds(w,varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'ds',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ds2(w,varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'ds2',varargin{:});
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function [figureHandle, axesHandle, plotHandle] = pa(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'pa',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'paoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'ps',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps2(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'ps2',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps2oc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'sp2oc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets on the current figure
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'psoc',varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 3d Plotting functions
        %------------------------------------------------------------------
        function [figureHandle, axesHandle, plotHandle] = sliceomatic(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'sliceomatic',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = sliceomatic_overview(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic with view straight down one of the axes
            [figureHandle, axesHandle, plotHandle] = throw_unavailable_( ...
                w,'sliceomatic_overview',varargin{:});
        end
    end
end