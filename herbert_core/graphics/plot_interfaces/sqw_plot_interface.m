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
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = dd(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout= de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = de(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = dh(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = dl(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = dm(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = dp(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pd(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pdoc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pe(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = peoc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ph(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = phoc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pl(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ploc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pm(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pmoc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = pp(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        function varargout = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object or array of objects on the current plot
            data = sqw_plot_interface.convert_to_dnd(w);
            [fig_,axes_,plot_] = ppoc(data,varargin{:});
            % Output only if requested
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
            end
        end
        %------------------------------------------------------------------
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
    methods(Static,Access=protected)
        function data = convert_to_dnd(w)
            % convert to dnd single sqw or array of sqw objects and check
            % if array objects have the same image dimensionality
            data = dnd(w);
            if iscell(data)
                error('HORACE:plotting:invalid_argument', ...
                    'Can not plot array of sqw objects with different images dimensionality')
            end
        end
    end
end