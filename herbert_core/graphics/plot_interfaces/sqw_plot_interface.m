classdef sqw_plot_interface < data_plot_interface
    % Class defines all functions may be used for plotting various sqw
    % objects
    methods
        %------------------------------------------------------------------        
        % 1d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function [figureHandle, axesHandle, plotHandle] = dd(w,varargin)
            % Draws a plot of markers, error bars and lines of a 1D sqw 
            % or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'dd',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'de',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'dh',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'dl',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'dm',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'dp',varargin{:});
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function [figureHandle, axesHandle, plotHandle] = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pd',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pdoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pe',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'peoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ph',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'phoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pl',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ploc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pm',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pmoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pp',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ppoc',varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 2d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function [figureHandle, axesHandle, plotHandle] = da(w,varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'da',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ds(w,varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ds',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ds2(w,varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ds2',varargin{:});
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function [figureHandle, axesHandle, plotHandle] = pa(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'pa',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'paoc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ps',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps2(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset 
            % or array of datasets
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ps2',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps2oc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'ps2oc',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'psoc',varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 3d Plotting functions
        %------------------------------------------------------------------
        function [figureHandle, axesHandle, plotHandle] = sliceomatic(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'sliceomatic',varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = sliceomatic_overview(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic with view straight down one of the axes
            [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
                w,nargout,'sliceomatic_overview',varargin{:});
        end
       end
end