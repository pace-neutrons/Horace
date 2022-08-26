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
                delegate_to_dnd_(w,nout,'dd',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'dd',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end
        end
        function varargout= de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'de',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'de',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end
        end
        function varargout = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'dh',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'dh',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end
        end
        function varargout = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_( ...
                    w,nout,'dl',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'dl',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end
        end
        function varargout = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            varargout = delegate_to_dnd_( ...
                w,nargout,'dm',varargin{:});
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'dm',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'dm',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end

        end
        function varargout = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'dp',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'dp',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'pd',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'pd',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end
        end
        function varargout = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'pdoc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'pdoc',varargin{:});
                for i=1:nout
                    varargout{i} = out{i};
                end
            end
        end
        function varargout = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            nout = nargout;
            out = delegate_to_dnd_(w,nout,'pe',varargin{:});
            for i=1:nout
                varargout{i} = out{i};
            end

        end
        function varargout = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'peoc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'peoc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ph',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ph',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'phoc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'phoc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'pl',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'pl',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ploc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ploc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'pm',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'pm',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'pmoc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'pmoc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'pp',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'pp',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ppoc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ppoc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
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
                delegate_to_dnd_(w,nout,'da',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'da',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ds(w,varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ds',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ds',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ds2(w,varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ds2',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ds2',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'pa',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'pa',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'paoc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'paoc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ps(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ps',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ps',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ps2(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset
            % or array of datasets
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ps2',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ps2',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = ps2oc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'ps2oc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'ps2oc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'psoc',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'psoc',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
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
                delegate_to_dnd_(w,nout,'sliceomatic',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'sliceomatic',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
        function varargout = sliceomatic_overview(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic with view straight down one of the axes
            nout = nargout;
            if nout == 0
                delegate_to_dnd_(w,nout,'sliceomatic',varargin{:});
            else
                out = delegate_to_dnd_(w,nout,'sliceomatic',varargin{:});
                for i=1:nout; varargout{i} = out{i}; end
            end
        end
    end
end