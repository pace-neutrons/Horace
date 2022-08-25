classdef (Abstract=true) sqw_plot_interface < data_plot_interface
    % Class defines all functions may be used for plotting various sqw
    % objects
    methods
        %------------------------------------------------------------------
        % 1d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function varargout = dd(w,varargin)
            % Draws a plot of markers, error bars and lines of a 1D sqw
            % or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'dd',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'dd',varargin{:});
            end
        end
        function varargout= de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'de',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'de',varargin{:});
            end
        end
        function varargout = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'dh',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'dh',varargin{:});
            end
        end
        function varargout = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'dl',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'dl',varargin{:});
            end
        end
        function varargout = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            varargout = delegate_to_dnd_( ...
                w,nargout,'dm',varargin{:});
        end
        function varargout = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'dp',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'dp',varargin{:});
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pd',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pd',varargin{:});
            end
        end
        function varargout = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pdoc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pdoc',varargin{:});
            end
        end
        function varargout = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pe',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pe',varargin{:});
            end
        end
        function varargout = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'peoc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'peoc',varargin{:});
            end
        end
        function varargout = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ph',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ph',varargin{:});
            end
        end
        function varargout = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'phoc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'phoc',varargin{:});
            end
        end
        function varargout = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pl',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pl',varargin{:});
            end
        end
        function varargout = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ploc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ploc',varargin{:});
            end
        end
        function varargout = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pm',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pm',varargin{:});
            end
        end
        function varargout = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pmoc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pmoc',varargin{:});
            end
        end
        function varargout = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pp',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pp',varargin{:});
            end
        end
        function varargout = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ppoc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ppoc',varargin{:});
            end
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 2d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function varargout = da(w,varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'da',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'da',varargin{:});
            end
        end
        function varargout = ds(w,varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ds',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ds',varargin{:});
            end
        end
        function varargout = ds2(w,varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ds2',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ds2',varargin{:});
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'pa',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'pa',varargin{:});
            end
        end
        function varargout = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'paoc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'paoc',varargin{:});
            end
        end
        function varargout = ps(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ps',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ps',varargin{:});
            end
        end
        function varargout = ps2(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset
            % or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ps2',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ps2',varargin{:});
            end
        end
        function varargout = ps2oc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'ps2oc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'ps2oc',varargin{:});
            end
        end
        function varargout = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'psoc',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'psoc',varargin{:});
            end
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 3d Plotting functions
        %------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'sliceomatic',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'sliceomatic',varargin{:});
            end
        end
        function varargout = sliceomatic_overview(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic with view straight down one of the axes
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'sliceomatic_overview',varargin{:});
            else
                varargout{1:nout} = delegate_to_dnd_( ...
                    w,nout,'sliceomatic_overview',varargin{:});
            end
        end
    end
end