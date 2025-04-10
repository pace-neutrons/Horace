classdef (Abstract=true) sqw_plot_interface < data_plot_interface
    % Abstract class that defines the interface to all sqw plotting functions.
    %
    % This interface defines concrete implementations of the abstract methods
    % whose interfaces defined in the abstract class data_plot_interface.
    
    
    % Developer notes:
    % ----------------
    % The concrete implementations here perform conversion of sqw objects to
    % the corresponding d1d, d2d or d3d objects, and then call the plot methods
    % of those objects.
    
    
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
            % Draws a plot of markers, error bars and lines of a 1D sqw object or
            % array of objects.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dd(data, varargin{:});
        end
        
        function varargout= de(w, varargin)
            % Draws a plot of error bars of a 1D sqw object or array of objects.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = de(data, varargin{:});
        end
        
        function varargout = dh(w, varargin)
            % Draws a histogram plot of a 1D sqw object or array of objects.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dh(data, varargin{:});
        end
        
        function varargout = dl(w, varargin)
            % Draws a line plot of a 1D sqw object or array of objects.
            %   >> dl(w)
            %   >> dl(w,xlo,xhi)
            %   >> dl(w,xlo,xhi,ylo,yhi)
            %
            % Advanced use:
            %   >> dl(w,...,'name',fig_name)        % draw with name = fig_name
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = dl(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dl(data, varargin{:});
        end
        
        function varargout = dm(w, varargin)
            % Draws a marker plot of a 1D sqw object or array of objects.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dm(data, varargin{:});
        end
        
        function varargout = dp(w, varargin)
            % Draws a plot of markers and error bars of a 1D sqw object or array of
            % objects.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = dp(data, varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        % --------        
        function varargout = pd(w, varargin)
            % Overplot markers, error bars and lines of a 1D sqw object or array of
            % objects on an existing plot.
            %
            %   >> pd(w)
            %
            % Advanced use:
            %   >> pd(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pd(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pd(data, varargin{:});
        end
        
        function varargout = pdoc(w, varargin)
            % Overplot markers, error bars and lines of a 1D sqw object or array of
            % objects on the current plot.
            %
            %   >> pdoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pdoc(w)

            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pdoc(data, varargin{:});
        end
        
        function varargout = pe(w, varargin)
            % Overplot error bars of a 1D sqw object or array of objects on an
            % existing plot.
            %
            %   >> pe(w)
            %
            % Advanced use:
            %   >> pe(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pe(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pe(data, varargin{:});
        end
        
        function varargout = peoc(w, varargin)
            % Overplot error bars of a 1D sqw object or array of objects on the
            % current plot.
            %
            %   >> peoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = peoc(w)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = peoc(data, varargin{:});
        end
        
        function varargout = ph(w, varargin)
            % Overplot histogram of a 1D sqw object or array of objects on an
            % existing plot.
            %
            %   >> ph(w)
            %
            % Advanced use:
            %   >> ph(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ph(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ph(data, varargin{:});
        end
        
        function varargout = phoc(w, varargin)
            % Overplot histogram of a 1D sqw object or array of objects on the
            % current plot.
            %
            %   >> phoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = phoc(w)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = phoc(data, varargin{:});
        end
        
        function varargout = pl(w, varargin)
            % Overplot line of a 1D sqw object or array of objects on an existing plot.
            %
            %   >> pl(w)
            %
            % Advanced use:
            %   >> pl(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pl(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pl(data, varargin{:});
        end
        
        function varargout = ploc(w, varargin)
            % Overplot line of a 1D sqw object or array of objects on the current plot.
            %
            %   >> ploc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ploc(w)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ploc(data, varargin{:});
        end
        
        function varargout = pm(w, varargin)
            % Overplot markers of a 1D sqw object or array of objects on an existing plot.
            %
            %   >> pm(w)
            %
            % Advanced use:
            %   >> pm(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pm(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pm(data, varargin{:});
        end
        
        function varargout = pmoc(w, varargin)
            % Overplot markers of a 1D sqw object or array of objects on the current plot.
            %
            %   >> pmoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pmoc(w)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pmoc(data, varargin{:});
        end
        
        function varargout = pp(w, varargin)
            % Overplot markers and error bars of a 1D sqw object or array of
            % objects on an existing plot.
            %
            %   >> pp(w)
            %
            % Advanced use:
            %   >> pp(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pp(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pp(data, varargin{:});
        end
        
        function varargout = ppoc(w, varargin)
            % Overplot markers and error bars for a 1D dnd object or array of
            % objects on the current plot.
            %
            %   >> ppoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ppoc(w)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ppoc(data, varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % 2D Plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        function varargout = da(w, varargin)
            % Draw an area plot of a 2D sqw dataset or array of datasets.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = da(data, varargin{:});
        end
        
        function varargout = ds(w, varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ds(data, varargin{:});
        end
        
        function varargout = ds2(w, varargin)
            % Draw a surface plot of a 2D sqw dataset or array of datasets
            % with the possibility of providing a second dataset as the source of the
            % image colour scale.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ds2(data, varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w, varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets.
            %
            %   >> pa(w)
            %
            % Advanced use:
            %   >> pa(w,'name',fig_name)        % overplot on figure with name = fig_name
            %                                   % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = pa(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = pa(data, varargin{:});
        end
        
        function varargout = paoc(w, varargin)
            % Overplot an area plot of a 2D sqw dataset or array of datasets on the
            % current figure.
            %
            %   >> paoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = paoc(w)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = paoc(data, varargin{:});
        end
        
        function varargout = ps(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets.
            %
            %   >> ps(w)
            %
            % Advanced use:
            %   >> ps(w,'name',fig_name) % overplot on figure with name = fig_name
            %                            % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ps(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps(data, varargin{:});
        end
        
        function varargout = psoc(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets on
            % the current figure.
            %
            %   >> psoc(w)
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = psoc(w)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = psoc(data, varargin{:});
        end
        
        function varargout = ps2(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets
            % with the possibility of providing a second dataset as the source of the
            % image colour scale.
            %
            %   >> ps2(w)
            %
            % Advanced use:
            %   >> ps2(w,'name',fig_name) % overplot on figure with name = fig_name
            %                             % or figure with given figure number or handle
            %
            % Return figure, axes and plot handles:
            %   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...)
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps2(data, varargin{:});
        end
        
        function varargout = ps2oc(w, varargin)
            % Overplot a surface plot of a 2D sqw dataset or array of datasets on
            % the current figure with the possibility of providing a second
            % dataset as the source of image colour scale.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = ps2oc(data, varargin{:});
        end
        
        %------------------------------------------------------------------
        % 3D Plotting functions
        %------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots a 3D sqw object using sliceomatic.
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
            
            data = sqw_plot_interface.convert_to_dnd(w);
            varargout = cell(1, nargout);   % output only if requested
            [varargout{:}] = sliceomatic(data, varargin{:});
        end
        
        function varargout = sliceomatic_overview(w, varargin)
            % Plots a 3D sqw object using sliceomatic viewed straight down one of the axes.
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
