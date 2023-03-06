classdef (Abstract=true) dnd_plot_interface < data_plot_interface
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



            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xy');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'dd',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = de(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xy');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'de',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dh(w,varargin)
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

            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xy');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'dh',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dl(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xy');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'dl',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dm(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xy');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'dm',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = dp(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xy');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'dp',class(w),opt,varargin{:});
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function [figureHandle, axesHandle, plotHandle] = pd(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'pd',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pdoc(w,varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            %
            %   >> pdoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pdoc(w)


            % Check input arguments
            opt=struct('newplot',false,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'pdoc',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pe(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'pe',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = peoc(w,varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> peoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = peoc(w)


            % Check input arguments
            opt=struct('newplot',false,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'peoc',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ph(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'ph',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = phoc(w,varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> phoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = phoc(w)


            % Check input arguments
            opt=struct('newplot',false,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'phoc',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pl(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'pl',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ploc(w,varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> ploc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ploc(w)


            % Check input arguments
            opt=struct('newplot',false,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'ploc',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pm(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'pm',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pmoc(w,varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> pmoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pmoc(w)


            % Check input arguments
            opt=struct('newplot',false,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'pmoc',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = pp(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_oned');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'pp',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ppoc(w,varargin)
            % Overplot markers and error bars for a 1D dnd object
            % or array of objects on the current plot
            %
            %   >> ppoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ppoc(w)


            % Check input arguments
            opt=struct('newplot',false,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
                IX_dataset_1d(w),nargout,'ppoc',class(w),opt,varargin{:});
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % 2d Plotting functions
        %------------------------------------------------------------------
        % PLOT
        function [figureHandle, axesHandle, plotHandle] = da(w,varargin)
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


            % Strip trailing option, if present
            [opt_adjust,opt_present]= ...
                data_plot_interface.adjust_aspect_option(varargin);

            % Check input arguments
            nam=get_global_var('horace_plot','name_area');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xyz');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_( ...
                IX_dataset_2d(w),nargout,'da',class(w),opt, ...
                varargin{1:end-opt_present});
            if opt_adjust
                adjust_aspect_2d_(w)
            end

        end
        function [figureHandle, axesHandle, plotHandle] = ds(w,varargin)
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


            % Strip trailing option, if present
            [opt_adjust,opt_present]=data_plot_interface.adjust_aspect_option(varargin);

            % Check input arguments
            nam=get_global_var('horace_plot','name_surface');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xyz');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_( ...
                IX_dataset_2d(w),nargout,'ds',class(w),opt, ...
                varargin{1:end-opt_present});
            if opt_adjust
                adjust_aspect_2d_(w)
            end

        end
        function [figureHandle, axesHandle, plotHandle] = ds2(w,varargin)
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



            % Strip trailing option, if present
            [opt_adjust,opt_present]=data_plot_interface.adjust_aspect_option(varargin);

            nam=get_global_var('horace_plot','name_surface');
            opt=struct('newplot',true,'default_name',nam,'lims_type','xyz');

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_2p_( ...
                w,nargout,'ds2',class(w),opt,varargin{1:end-opt_present});
            if opt_adjust
                adjust_aspect_2d_(w)
            end
        end
        %------------------------------------------------------------------
        % OVERPLOT
        function [figureHandle, axesHandle, plotHandle] = pa(w,varargin)
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

            % Check input arguments
            nam=get_global_var('horace_plot','name_area');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_( ...
                IX_dataset_2d(w),nargout,'pa',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = paoc(w,varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            %
            %   >> paoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = paoc(w)

            % Check input arguments
            nam=get_global_var('horace_plot','name_area');
            opt=struct('newplot',false,'default_name',nam,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_( ...
                IX_dataset_2d(w),nargout,'paoc',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps(w,varargin)
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


            % Check input arguments
            nam=get_global_var('horace_plot','name_surface');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_( ...
                IX_dataset_2d(w),nargout,'ps',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps2(w,varargin)
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

            % Check input arguments
            nam=get_global_var('horace_plot','name_surface');
            opt=struct('newplot',false,'default_name',nam);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_2p_( ...
                w,nargout,'ps2',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = ps2oc(w,varargin)
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



            nam=get_global_var('horace_plot','name_surface');
            opt=struct('newplot',false,'default_name',nam,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_2p_( ...
                w,nargout,'ps2oc',class(w),opt,varargin{:});
        end
        function [figureHandle, axesHandle, plotHandle] = psoc(w,varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            %
            %   >> psoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = psoc(w)


            % Check input arguments
            nam=get_global_var('horace_plot','name_surface');
            opt=struct('newplot',false,'default_name',nam,'over_curr',true);

            [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_( ...
                IX_dataset_2d(w),nargout,'psoc',class(w),opt,varargin{:});
        end
        %------------------------------------------------------------------
    end
end