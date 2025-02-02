classdef (Abstract=true) sqw_plot_interface < data_plot_interface
    % Abstract class that defines the interface to all sqw plotting functions.
    
    %----------------------------------------------------------------------
    % Plotting methods
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------------------
        % 1d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        % ----
        function varargout = dd(w,varargin)
            % Draws a plot of markers, error bars and lines of a 1D sqw object
            % or array of objects.
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dd(data, varargin{:});
        end
        
        function varargout= de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = de(data, varargin{:});
        end
        
        function varargout = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dh(data, varargin{:});
        end
        
        function varargout = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dl(data, varargin{:});
        end
        
        function varargout = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dm(data, varargin{:});
        end
        
        function varargout = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dp(data, varargin{:});
        end
        
        %------------------------------------------------------------------
        % OVERPLOT
        % --------        
        function varargout = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pd(data, varargin{:});
        end
        function varargout = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pdoc(data, varargin{:});
        end
        function varargout = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pe(data, varargin{:});
        end
        function varargout = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = peoc(data, varargin{:});
        end
        function varargout = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ph(data, varargin{:});
        end
        function varargout = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = phoc(data, varargin{:});
        end
        function varargout = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pl(data, varargin{:});
        end
        function varargout = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ploc(data, varargin{:});
        end
        function varargout = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pm(data, varargin{:});
        end
        function varargout = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pmoc(data, varargin{:});
        end
        function varargout = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pp(data, varargin{:});
        end
        function varargout = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ppoc(data, varargin{:});
        end
        
        %------------------------------------------------------------------
        % 2d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function varargout = da(w,varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = da(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ds(w,varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ds(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ds2(w,varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ds2(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pa(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = paoc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ps(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ps(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ps2(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset
            % or array of datasets
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ps2(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ps2oc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ps2oc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = psoc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        
        %------------------------------------------------------------------
        % 3d Plotting functions
        %------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = sliceomatic(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = sliceomatic_overview(w, varargin)
            % Plots 3D sqw or dnd object using sliceomatic with view straight down one of the axes
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = sliceomatic_overview(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
    end
    
    %----------------------------------------------------------------------
    % Static utility methods
    %----------------------------------------------------------------------
    methods(Static, Access=protected)
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
                error('HORACE:plotting:invalid_argument', ...
                    ['Cannot plot array of sqw objects with different ', ...
                    'images dimensionality'])
            end
        end
    end
end