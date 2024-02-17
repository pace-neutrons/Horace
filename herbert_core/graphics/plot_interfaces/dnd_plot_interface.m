classdef (Abstract=true) dnd_plot_interface < data_plot_interface
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
            %
            %   >> dd(w)
            %   >> dd(w,xlo,xhi)
            %   >> dd(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> dd(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = dd(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = dd(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = de(w,varargin)
            % Draws a plot of error bars of a 1D sqw or dnd object or array of objects
            %
            %   >> de(w)
            %   >> de(w,xlo,xhi)
            %   >> de(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> de(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = de(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = de(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = dh(w,varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects

            %   >> dh(w)
            %   >> dh(w,xlo,xhi)
            %   >> dh(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> dh(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = dh(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = dh(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = dl(w,varargin)
            % Draws a line plot of a 1D sqw or dnd object or array of objects
            %   >> dl(w)
            %   >> dl(w,xlo,xhi)
            %   >> dl(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> dl(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = dl(w,...)


            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = dl(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = dm(w,varargin)
            % Draws a marker plot of a 1D sqw or dnd object or array of objects
            %
            %   >> dm(w)
            %   >> dm(w,xlo,xhi)
            %   >> dm(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> dm(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = dm(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = dm(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = dp(w,varargin)
            % Draws a plot of markers and error bars for a 1D sqw or dnd object or array of objects
            %
            %   >> dp(w)
            %   >> dp(w,xlo,xhi)
            %   >> dp(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> dp(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = dp(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = dp(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pd(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on an existing plot
            %
            %   >> pd(w)
            %
            % Advanced use:
            %   >> pd(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pd(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pd(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            %
            %   >> pdoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pdoc(w)
            data = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pdoc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end

        end
        function varargout = pe(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on an existing plot
            %
            %   >> pe(w)
            %
            % Advanced use:
            %   >> pe(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pe(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pe(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end

        end
        function varargout = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> peoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = peoc(w)

            data = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = peoc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = ph(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on an existing plot
            %
            %   >> ph(w)
            %
            % Advanced use:
            %   >> ph(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ph(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = ph(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> phoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = phoc(w)

            data = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = phoc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = pl(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on an existing plot
            %
            %   >> pl(w)
            %
            % Advanced use:
            %   >> pl(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pl(w,...)


            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pl(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> ploc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ploc(w)

            data = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = ploc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = pm(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of
            % objects on an existing plot
            %
            %   >> pm(w)
            %
            % Advanced use:
            %   >> pm(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pm(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pm(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> pmoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pmoc(w)

            data = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pmoc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = pp(w,varargin)
            % Overplot markers and error bars for a 1D sqw or dnd object
            % or array of objects on an existing plot
            %
            %   >> pp(w)
            %
            % Advanced use:
            %   >> pp(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pp(w,...)

            [data,argi] = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pp(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D dnd object
            % or array of objects on the current plot
            %
            %   >> ppoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ppoc(w)

            data = dnd_plot_interface.parse_partial_1D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = ppoc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 2d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function varargout = da(w,varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets
            %
            %   >> da(w)
            %   >> da(w,xlo,xhi)
            %   >> da(w,xlo,xhi,ylo,yhi)
            %   >> da(w,xlo,xhi,ylo,yhi,zlo,zhi)
            %
            % Advanced use:
            %   >> da(w,...,'name',fig_name)        % Draw with name = fig_name
            %
            %   >> da(w,...,'-noaspect')            % Do not change aspect ratio
            %                                       % according to data axes unit lengths
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = da(w,...)


            [data,adjust,argi] = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = da(data,argi{:});
            if adjust
                adjust_aspect_2d_(w)
            end
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = ds(w,varargin)
            % Draw a surface plot of a 2D sqw dataset
            % or array of datasets
            %
            %   >> ds(w)
            %   >> ds(w,xlo,xhi)
            %   >> ds(w,xlo,xhi,ylo,yhi)
            %   >> ds(w,xlo,xhi,ylo,yhi,zlo,zhi)
            %
            % Advanced use:
            %   >> ds(w,...,'name',fig_name)        % Draw with name = fig_name
            %
            %   >> ds(w,...,'-noaspect')            % Do not change aspect ratio
            %                                       % according to data axes unit lengths
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ds(w,...)


            [data,adjust,argi] = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = ds(data,argi{:});
            if adjust
                adjust_aspect_2d_(w)
            end
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout= ds2(w,varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            %
            %   >> ds2(w)       % Use error bars to set colour scale
            %   >> ds2(w,wc)    % Signal in wc sets colour scale
            %                   %   wc can be any object with a signal array with same
            %                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
            %                   %  a numeric array.
            %                   %   - If w is an array of objects, then wc must contain
            %                   %     the same number of objects.
            %                   %   - If wc is a numeric array then w must be a scalar
            %                   %     object.
            %   >> ds2(...,xlo,xhi)
            %   >> ds2(...,xlo,xhi,ylo,yhi)
            %   >> ds2(...,xlo,xhi,ylo,yhi,zlo,zhi)
            %
            % Differs from ds in that the signal sets the z axis, and the colouring is
            % set by the error bars, or by another object. This enables two related
            % functions to be plotted (e.g. dispersion relation where the 'signal'
            % array holds the energy and the error array holds the spectral weight).
            %
            % Advanced use:
            %   >> ds2(w,...,'name',fig_name)       % Draw with name = fig_name
            %
            %   >> ds2(w,...,'-noaspect')           % Do not change aspect ratio
            %                                       % according to data axes unit lengths
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ds2(...)

            if nargin>1 && isa(varargin{1},'dnd_plot_interface')
                varargin{1} = IX_dataset_2d(varargin{1});
            end
            [data,adjust,argi] = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = ds2(data,argi{:});
            if adjust
                adjust_aspect_2d_(w)
            end
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets
            %
            %   >> pa(w)
            %
            % Advanced use:
            %   >> pa(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pa(w,...)

            [data,~,argi] = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = pa(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            %
            %   >> paoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = paoc(w)

            data = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = paoc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = ps(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            %
            %   >> ps(w)
            %
            % Advanced use:
            %   >> ps(w,'name',fig_name) % overplot on figure with name = fig_name
            %                            % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ps(w,...)

            [data,~,argi] = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = ps(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = ps2(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset
            % or array of datasets
            %
            %   >> ps(w)
            %
            % Advanced use:
            %   >> ps(w,'name',fig_name)  % overplot on figure with name = fig_name
            %                             % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ps(w,...)

            if nargin>1 && isa(varargin{1},'dnd_plot_interface')
                varargin{1} = IX_dataset_2d(varargin{1});
            end
            [data,~,argi] = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = ps2(data,argi{:});
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = ps2oc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            %
            %
            %   >> ps2oc(w)     % Use error bars to set colour scale
            %   >> ps2oc(w,wc)  % Signal in wc sets colour scale
            %                   %   wc can be any object with a signal array with same
            %                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
            %                   %  a numeric array.
            %                   %   - If w is an array of objects, then wc must contain
            %                   %     the same number of objects.
            %                   %   - If wc is a numeric array then w must be a scalar
            %                   %     object.
            %
            % Differs from ds in that the signal sets the z axis, and the colouring is
            % set by the error bars, or by another object. This enables two related
            % functions to be plotted (e.g. dispersion relation where the 'signal'
            % array holds the energy and the error array holds the spectral weight).
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ps2oc(w)

            data = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            if nargin>1 && isa(varargin{1},'dnd_plot_interface')
                scale = IX_dataset_2d(varargin{1});
                [figureHandle, axesHandle, plotHandle] = ps2oc(data,scale);
            else
                [figureHandle, axesHandle, plotHandle] = ps2oc(data);
            end
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        function varargout = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            %
            %   >> psoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = psoc(w)

            data = dnd_plot_interface.parse_partial_2D_arg(w,varargin{:});
            [figureHandle, axesHandle, plotHandle] = psoc(data);
            if nargout>0
                varargout = data_plot_interface.set_argout(nargout,figureHandle,axesHandle,plotHandle);
            end
        end
        %------------------------------------------------------------------
    end
    methods(Static,Access=protected)
        function [out,argi] = parse_partial_1D_arg(w,varargin)
            % parse arguments of 1D plot and strip/add things, related to
            % dnd_plot_interface leaving other arguments to process on
            % IX_dataset level.
            out = IX_dataset_1d(w);
            is_name = cellfun(@(x)strcmp(char(x),'name'),varargin);
            if any(is_name)
                argi = varargin;
            else
                argi = [varargin(:);'name';'Horace 1D plot'];
            end
        end
        function [out,adjust,argi] = parse_partial_2D_arg(w,varargin)
            % parse arguments of 2D plot and strip/add things, related to
            % dnd_plot_interface leaving other arguments to process on
            % IX_dataset level.
            out = IX_dataset_2d(w);
            if nargout<2
                return;
            end
            aspect_here = cellfun(@(x)ismember({'-aspec','-noaspect'},char(x)),varargin);
            if any(aspect_here)
                aspect_key = varargin(aspect_here);
                argi = varargin(~aspect_here);
                if strcmp(aspect_key,'-aspect')
                    adjust = true;
                else
                    adjust = false;
                end
            else
                argi = varargin;
                adjust = true;
            end

            is_name = cellfun(@(x)strcmp(char(x),'name'),argi);
            if any(is_name)
                argi = varargin;
            else
                argi = [varargin(:);'name';'Horace 2D plot'];
            end
        end

    end
end