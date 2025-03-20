classdef (Abstract=true) dnd_plot_interface < data_plot_interface
    % Abstract class that defines the interface to all dnd plotting functions.
    % That is, to the Horace d1d, d2d, d3d... objects
    
    %---------------------------------------------------------------------------
    % Plotting methods
    %---------------------------------------------------------------------------
    methods
        %-----------------------------------------------------------------------
        % 1D plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        % ----
        function varargout = dd(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dd(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = de(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = de(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = dh(w, varargin)
            % Draws a histogram plot of a 1D sqw or dnd object or array of objects
            %
            %   >> dh(w)
            %   >> dh(w,xlo,xhi)
            %   >> dh(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> dh(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = dh(w,...)
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dh(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = dl(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dl(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = dm(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dm(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = dp(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dp(IX_dataset_1d(w), varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        % --------
        function varargout = pd(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pd(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = pdoc(w, varargin)
            % Overplot markers, error bars and lines for a 1D sqw or dnd object
            % or array of objects on the current plot
            %
            %   >> pdoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pdoc(w)
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pdoc(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = pe(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pe(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = peoc(w, varargin)
            % Overplot error bars for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> peoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = peoc(w)
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = peoc(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = ph(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ph(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = phoc(w, varargin)
            % Overplot histogram for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> phoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = phoc(w)
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = phoc(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = pl(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pl(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = ploc(w, varargin)
            % Overplot line for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> ploc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ploc(w)
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ploc(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = pm(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pm(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = pmoc(w, varargin)
            % Overplot markers for a 1D sqw or dnd object or array of objects
            % on the current plot
            %
            %   >> pmoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pmoc(w)
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pmoc(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = pp(w, varargin)
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
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pp(IX_dataset_1d(w), varargin{:});
        end
        
        function varargout = ppoc(w, varargin)
            % Overplot markers and error bars for a 1D dnd object
            % or array of objects on the current plot
            %
            %   >> ppoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ppoc(w)
            
            data_plot_interface.default_name('Horace 1D plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ppoc(IX_dataset_1d(w), varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % 2D plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        function varargout = da(w, varargin)
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
            
            data_plot_interface.default_name('Horace area plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            [args, adjust_aspect] = dnd_plot_interface.strip_aspect_option(varargin{:});
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = da(IX_dataset_2d(w), args{:});
            if adjust_aspect
                dnd_plot_interface.adjust_aspect_ratio(w)
            end
        end
        
        function varargout = ds(w, varargin)
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
            
            data_plot_interface.default_name('Horace surface plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            [args, adjust_aspect] = dnd_plot_interface.strip_aspect_option(varargin{:});
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ds(IX_dataset_2d(w), args{:});
            if adjust_aspect
                dnd_plot_interface.adjust_aspect_ratio(w)
            end
        end
        
        function varargout= ds2(w, varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            % with possibility of providing second dataset as source of
            % image colour scale
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
            
            data_plot_interface.default_name('Horace surface plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            [args, adjust_aspect] = dnd_plot_interface.strip_aspect_option(varargin{:});
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ds2(IX_dataset_2d(w), args{:});
            if adjust_aspect
                dnd_plot_interface.adjust_aspect_ratio(w)
            end
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w, varargin)
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
            
            data_plot_interface.default_name('Horace area plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pa(IX_dataset_2d(w), varargin{:});
        end
        
        function varargout = paoc(w, varargin)
            % Overplot an area plot of a 2D sqw dataset or
            % array of datasets on the current figure
            %
            %   >> paoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = paoc(w)
            
            data_plot_interface.default_name('Horace area plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = paoc(IX_dataset_2d(w), varargin{:});
        end
        
        function varargout = ps(w, varargin)
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
            
            data_plot_interface.default_name('Horace surface plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps(IX_dataset_2d(w), varargin{:});
        end
        
        function varargout = psoc(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of
            % datasets on the current figure
            %
            %   >> psoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = psoc(w)
            
            data_plot_interface.default_name('Horace surface plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = psoc(IX_dataset_2d(w), varargin{:});
        end
        
        function varargout = ps2(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset
            % or array of datasets
            % with possibility of providing second dataset as source of
            % image colour scale
            %
            %   >> ps2(w)
            %
            % Advanced use:
            %   >> ps2(w,'name',fig_name)  % overplot on figure with name = fig_name
            %                             % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...)
            
            data_plot_interface.default_name('Horace surface plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps2(IX_dataset_2d(w), varargin{:});
        end
        
        function varargout = ps2oc(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or
            % array of datasets on the current figure
            % with possibility of providing second dataset as source of
            % image colour scale
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
            
            data_plot_interface.default_name('Horace surface plot');
            cleanup = onCleanup(@()data_plot_interface.default_name());
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps2oc(IX_dataset_2d(w), varargin{:});
            
        end
        
        %-----------------------------------------------------------------------
        % 3D plotting functions
        %-----------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots a d3d object using sliceomatic
            %
            %   >> sliceomatic (w)
            %
            % To enable isonormals:
            %   >> sliceomatic (w, ..., 'isonormals', true, ...)
            %
            % Advanced use:
            %   >> sliceomatic (w, ..., 'name', fig_name, ...)   % draw with name = fig_name
            %
            %   >> sliceomatic (w,...,'-noaspect')  % Do not change aspect ratio
            %                                       % according to data axes unit lengths
            %
            % Return figure and axes handles, and a structure with plot data:
            %   >> [fig_handle, axes_handle, plot_data] = sliceomatic (w, ...)
            %
            %
            % NOTES:
            %
            % - Ensure that the slice color plotting is in 'texture' mode -
            %      On the 'AllSlices' menu click 'Color Texture'. No indication will
            %      be made on this menu to show that it has been selected, but you can
            %      see the result if you right-click on an arrow indicating a slice on
            %      the graphics window.
            %
            % - To set the default for future Sliceomatic sessions -
            %      On the 'Object_Defaults' menu select 'Slice Color Texture'
            
            if numel(w)~=1 || dimensions(w)~=3
                error('HORACE:sliceomatic:invalid_argument', ...
                    'Sliceomatic only works for a single 3D dataset')
            end
            [args, adjust_aspect] = dnd_plot_interface.strip_aspect_option(varargin{:});  
            
            fig_name = 'Horace sliceomatic';
            pax = w.pax;
            dax = w.dax;    % permutation of projection axes to give display axes
            ulabel = w.label(pax(dax));     % labels in order of the display axes
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = sliceomatic (IX_dataset_3d(w), ...
                'x_axis', ulabel{1}, 'y_axis', ulabel{2}, 'z_axis', ulabel{3},...
                'name', fig_name, args{:});
            if adjust_aspect
                dnd_plot_interface.adjust_aspect_ratio(w)
            end
        end
        
        function varargout = sliceomatic_overview(w, varargin)
            % Plots a d3d object using sliceomatic viewed straight down one of the axes
            % When the slider for that axis is moved we get a series of what appear to be
            % two-dimensioonal slices.
            %
            %   >> sliceomatic_overview (w)         % down the third (i.e. vertical) axis
            %   >> sliceomatic_overview (w, axis)   % down the axis of choice (axis=1,2 or 3)
            %
            % To enable isonormals:
            %   >> sliceomatic_overview (w,... 'isonormals', true)
            %
            % Advanced use:
            %   >> sliceomatic_overview (w, ..., 'name', fig_name, ...)
            %                                               % draw with name = fig_name
            %
            %   >> sliceomatic_overview (w,...,'-noaspect') % Do not change aspect ratio
            %                                       % according to data axes unit lengths
            %
            % Return figure and axes handles, and a structure with plot data:
            %   >> [fig_handle, axes_handle, plot_data] = sliceomatic_overview (w, ...)
            %
            %
            % NOTES:
            %
            % - Ensure that the slice colour plotting is in 'texture' mode -
            %      On the 'AllSlices' menu click 'Colour Texture'. No indication will
            %      be made on this menu to show that it has been selected, but you can
            %      see the result if you right-click on an arrow indicating a slice on
            %      the graphics window.
            %
            % - To set the default for future Sliceomatic sessions -
            %      On the 'Object_Defaults' menu select 'Slice Colour Texture'
            
            if numel(w)~=1 || dimensions(w)~=3
                error('HORACE:sliceomatic:invalid_argument', ...
                    'Sliceomatic only works for a single 3D dataset')
            end
            [args, adjust_aspect] = dnd_plot_interface.strip_aspect_option(varargin{:});  
            
            fig_name = 'Horace sliceomatic';
            pax = w.pax;
            dax = w.dax;    % permutation of projection axes to give display axes
            ulabel = w.label(pax(dax));     % labels in order of the display axes
            
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = sliceomatic_overview (IX_dataset_3d(w), ...
                'x_axis', ulabel{1}, 'y_axis', ulabel{2}, 'z_axis', ulabel{3},...
                'name', fig_name, args{:});
            if adjust_aspect
                dnd_plot_interface.adjust_aspect_ratio(w)
            end
        end
    end
    
    
    %---------------------------------------------------------------------------
    % Static methods
    %---------------------------------------------------------------------------
    methods(Static,Access=protected)
        %-----------------------------------------------------------------------
        % Utility methods
        %
        % They are defined as static methods rather than utility functions so
        % that there is no danger whatever of a method of the first argument
        % being called, with all the possible hard to track errors that may
        % occur.
        %-----------------------------------------------------------------------
        function [args, adjust_aspect] = strip_aspect_option(varargin)
            % Find logical flag aspect or its negation in the argument list
            %
            %   >> [args, adjust_aspect] = strip_aspect_option(varargin)
            %
            % Input:
            % ------
            %   varargin        Input arguments (cell array)
            %
            % Output:
            % -------
            %   args            Input arguments with 'adjust' stripped out, and
            %                   the corresponding value if the inoput had it as
            %                   a keyword-argument pair.
            %
            %   adjust_aspect   True:  adjust aspect ratio
            %                   False: do not adjust the aspect ratio
            
            keyval_default = struct('aspect', 1);
            flagnames = {'aspect'};
            opt.keys_at_end = false;    % any position in arg list
            opt.prefix = '-';           % optional prefix to keywords
            [args, keyval] = parse_arguments(varargin, keyval_default, flagnames, opt);
            adjust_aspect = keyval.aspect;
        end
        
        
        %-----------------------------------------------------------------------
        function adjust_aspect_ratio(w)
            % Set aspect ratio for plotting 2D and 3D dnd objects
            %
            %   >> adjust_aspect_ratio(w)
            %
            % The aspect ratio can only be changed if
            % (1) the rescaling is the same for all objects in the array
            % (2) it is a permissible option for all objects in the array, as
            %     defined by w(i).axes.changes_aspect_ratio. [This property is
            %     opaque, but refactoring the original code which has its value
            %     caught means it needs to be retained pending deeper
            %     investigation.]
            %
            % If there is any reason why changing the aspect ratio doesn not
            % make sense e.g. the energy axis is not the same for all datasets,
            % just do nothing and quietly return.
            %
            % Input:
            % ------
            %   w       d2d or d3d object, or an array of such objects
            
            % Check the dnd dimensionality:
            if ~(dimensions(w(1))==2 || dimensions(w(1))==3)
                return
            end
            
            % Check that the object array elements all permit the aspect ratio
            % to be changed
            if ~all(arrayfun(@(x)(x.axes.changes_aspect_ratio), w(:)))
                return
            end
            
            % Loop over all elements of w to check that:
            % - None of them have an energy axis, or they all have an energy
            %   axis with the energy axis as the same plot axis;
            % - The unit of measure along each axis is the same for all objects.
            energy_axis = 4;        % the index of energy axis by convention in Horace
            for i=1:numel(w)
                pax = w(i).pax;
                dax = w(i).dax;     % permutation of projection axes to give display axes
                ulen = w(i).axes.ulen(pax(dax));% unit length in order of the display axes
                is_energy_axis = (pax(dax) == energy_axis);
                if i==1
                    % Get reference axis unit lengths and energy axis flag
                    ulen_ref = ulen;
                    is_energy_axis_ref = is_energy_axis;
                else
                    % Check the units of length match reference values within a
                    % tolerance, and the consistency of the presence or absence
                    % of an energy axis
                    if ~all(is_energy_axis == is_energy_axis_ref) || ...
                            max(abs((ulen-ulen_ref)./ulen_ref)) > 1e-8
                        return
                    end
                end
            end
            
            % All OK, so change the aspect ratio
            ulen_ref(is_energy_axis) = 0;   % indicate it will be ignored in call to aspect
            aspect(ulen_ref);
            colorslider('update');  % redraw the color bar as it may get distorted
        end
    end
    %---------------------------------------------------------------------------
end
