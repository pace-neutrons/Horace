classdef (Abstract=true) sqw_plot_interface < data_plot_interface
    % Abstract class that defines the interface to all sqw plotting functions.
    
    %---------------------------------------------------------------------------
    % Plotting methods
    %---------------------------------------------------------------------------
    methods
        %-----------------------------------------------------------------------
        % 1D Plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        % ----
        function varargout = dd(w, varargin)
            % Draws a plot of markers, error bars and lines of a 1D sqw object
            % or array of objects.
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dd(data, varargin{:});
        end
        
        function varargout= de(w, varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = de(data, varargin{:});
        end
        
        function varargout = dh(w, varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dh(data, varargin{:});
        end
        
        function varargout = dl(w, varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dl(data, varargin{:});
        end
        
        function varargout = dm(w, varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dm(data, varargin{:});
        end
        
        function varargout = dp(w, varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dp(data, varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        % --------        
        function varargout = pd(w, varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pd(data, varargin{:});
        end
        
        function varargout = pdoc(w, varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pdoc(data, varargin{:});
        end
        
        function varargout = pe(w, varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pe(data, varargin{:});
        end
        
        function varargout = peoc(w, varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = peoc(data, varargin{:});
        end
        
        function varargout = ph(w, varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ph(data, varargin{:});
        end
        
        function varargout = phoc(w, varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = phoc(data, varargin{:});
        end
        
        function varargout = pl(w, varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pl(data, varargin{:});
        end
        
        function varargout = ploc(w, varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ploc(data, varargin{:});
        end
        
        function varargout = pm(w, varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pm(data, varargin{:});
        end
        
        function varargout = pmoc(w, varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pmoc(data, varargin{:});
        end
        
        function varargout = pp(w, varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pp(data, varargin{:});
        end
        
        function varargout = ppoc(w, varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ppoc(data, varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % 2D Plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        function varargout = da(w, varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = da(data, varargin{:});
        end
        
        function varargout = ds(w, varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ds(data, varargin{:});
        end
        
        function varargout = ds2(w, varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ds2(data, varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w, varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pa(data, varargin{:});
        end
        
        function varargout = paoc(w, varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = paoc(data, varargin{:});
        end
        
        function varargout = ps(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps(data, varargin{:});
        end
        
        function varargout = psoc(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = psoc(data, varargin{:});
        end
        
        function varargout = ps2(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset
            % or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps2(data, varargin{:});
        end
        
        function varargout = ps2oc(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps2oc(data, varargin{:});
        end
        
        %------------------------------------------------------------------
        % 3D Plotting functions
        %------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = sliceomatic(data, varargin{:});
        end
        
        function varargout = sliceomatic_overview(w, varargin)
            % Plots 3D sqw object using sliceomatic with view straight down one
            % of the axes
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = sliceomatic_overview(data, varargin{:});
        end
    end
    
    
    %---------------------------------------------------------------------------
    % Static methods
    %---------------------------------------------------------------------------
    methods(Static, Access=protected)
        %-----------------------------------------------------------------------
        % Utility methods
        %
        % They are defined as static methods rather than utility functions so
        % that there is no danger whatever of a method of the first argument
        % being called, with all the possible hard to track errors that may
        % occur.
        %-----------------------------------------------------------------------
        function data = convert_to_dnd(w)
            % Convert an sqw object or array of objects to a dnd object or array
            % of objects.
            % We cannot just rely on the sqw method to performs this conversion
            % because we can only plot a set of objects which have the same
            % image dimensionality.
            % Use this function to convert and print an appropriate error
            % message.
            
            data = dnd(w);
            if iscell(data)
                error('HORACE:graphics:invalid_argument', ...
                    ['Cannot plot an array of sqw objects with different ', ...
                    'images dimensionality'])
            end
        end
    end
    %---------------------------------------------------------------------------
end
