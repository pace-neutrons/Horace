classdef (Abstract=true) data_plot_interface
    % Abstract class that defines the interface to all plotting functions

    properties
    end
    
    methods(Abstract)
        % This method is needed to enable the generic plot and plot_over methods
        % to work
        nd = dimensions();
    end

    %---------------------------------------------------------------------------
    % Plotting methods
    %---------------------------------------------------------------------------
    methods
        %-----------------------------------------------------------------------
        % Generic plotting interfaces for N-D objects
        %-----------------------------------------------------------------------
        % Plot 1D, 2D or 3D sqw or dnd object or array of objects
        varargout = plot(w, varargin)
        % Overplot 1D, 2D or 3D sqw or dnd object or array of objects
        varargout = plotover(w, varargin)

        %-----------------------------------------------------------------------
        % 1D plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        function varargout = dd(w, varargin)
            % Draws a plot of markers, error bars and lines for a 1D object
            % or array of objects.
            varargout = throw_unavailable_(w, 'dd', varargin{:});
        end
        function varargout = de(w, varargin)
            % Draws a plot of error bars for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'de', varargin{:});
        end
        function varargout = dh(w, varargin)
            % Draws a histogram plot for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'dh', varargin{:});
        end
        function varargout = dl(w, varargin)
            % Draws a line plot for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'dl', varargin{:});
        end
        function varargout = dm(w, varargin)
            % Draws a marker plot for a 1D object or array of objects.
            varargout = throw_unavailable_(w, 'dm', varargin{:});
        end
        function varargout = dp(w, varargin)
            % Draws a plot of markers and error bars for a 1D object or array of
            % objects.
            varargout = throw_unavailable_(w, 'dp', varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        function varargout = pd(w, varargin)
            % Overplot markers, error bars and lines for a 1D object or array of
            % objects on an existing plot.
            varargout = throw_unavailable_(w, 'pd', varargin{:});
        end
        function varargout = pdoc(w, varargin)
            % Overplot markers, error bars and lines for a 1D object or array of
            % objects on an existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'pdoc', varargin{:});
        end
        function varargout = pe(w, varargin)
            % Overplot error bars for a 1D object or array of objects on an
            % existing plot.
            varargout = throw_unavailable_(w, 'pe', varargin{:});
        end
        function varargout = peoc(w, varargin)
            % Overplot error bars for a 1D object or array of objects on an
            % existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'peoc', varargin{:});
        end
        function varargout = ph(w, varargin)
            % Overplot histogram for a 1D object or array of objects on an
            % existing plot.
            varargout = throw_unavailable_(w, 'ph', varargin{:});
        end
        function varargout = phoc(w, varargin)
            % Overplot histogram for a 1D object or array of objects on an
            % existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'phoc', varargin{:});
        end
        function varargout = pl(w, varargin)
            % Overplot line for a 1D object or array of objects on an existing
            % plot.
            varargout = throw_unavailable_(w, 'pl', varargin{:});
        end
        function varargout = ploc(w, varargin)
            % Overplot line for a 1D object or array of objects on an existing
            % plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'ploc', varargin{:});
        end
        function varargout = pm(w, varargin)
            % Overplot markers for a 1D object or array of objects on an
            % existing plot.
            varargout = throw_unavailable_(w, 'pm', varargin{:});
        end
        function varargout = pmoc(w, varargin)
            % Overplot markers for a 1D object or array of objects on an
            % existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'pmoc', varargin{:});
        end
        function varargout = pp(w, varargin)
            % Overplot markers and error bars for a 1D object or array of
            % objects on an existing plot.
            varargout = throw_unavailable_(w, 'pp', varargin{:});
        end
        function varargout = ppoc(w, varargin)
            % Overplot markers and error bars for a 1D object or array of
            % objects on an existing plot.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'ppoc', varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % 2D plotting functions
        %-----------------------------------------------------------------------
        % PLOT
        function varargout = da(w, varargin)
            % Draw an area plot of a 2D dataset or array of datasets.
            varargout = throw_unavailable_(w, 'da', varargin{:});
        end
        function varargout = ds(w, varargin)
            % Draw a surface plot of a 2D dataset or array of datasets.
            varargout = throw_unavailable_(w, 'ds', varargin{:});
        end
        function varargout = ds2(w, varargin)
            % Draw a surface plot of a 2D dataset or array of datasets, with the
            % possibility of providing second dataset(s) as the source of the
            % plot or plots colour scale.
            varargout = throw_unavailable_(w, 'ds2', varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % OVERPLOT
        function varargout = pa(w, varargin)
            % Overplot an area plot of a 2D dataset or array of datasets.
            varargout = throw_unavailable_(w, 'pa', varargin{:});
        end
        function varargout = paoc(w, varargin)
            % Overplot an area plot of a 2D dataset or array of datasets on the
            % current figure.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'paoc', varargin{:});
        end
        function varargout = ps(w, varargin)
            % Overplot a surface plot of a 2D dataset or array of datasets
            varargout = throw_unavailable_(w, 'ps', varargin{:});
        end
        function varargout = psoc(w, varargin)
            % Overplot a surface plot of a 2D dataset or array of datasets on
            % the current figure.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'psoc', varargin{:});
        end
        function varargout = ps2(w, varargin)            
            % Overplot a surface plot of a 2D dataset or array of datasets, with
            % the possibility of providing second dataset(s) as the source of
            % the plot or plots colour scale.
            varargout = throw_unavailable_(w, 'ps2', varargin{:});
        end
        function varargout = ps2oc(w, varargin)
            % Overplot a surface plot of a 2D dataset or array of datasets on
            % the current figure, with the possibility of providing second
            % dataset(s) as the source of the plot or plots colour scale.
            % Fails if dataset to overplot is missing.
            varargout = throw_unavailable_(w, 'ps2oc', varargin{:});
        end
        
        %-----------------------------------------------------------------------
        % 3D plotting functions
        %-----------------------------------------------------------------------
        function varargout = sliceomatic(w, varargin)
            % Plots 3D object using sliceomatic.
            varargout = throw_unavailable_(w, 'sliceomatic', varargin{:});
        end
        
        function varargout = sliceomatic_overview(w, varargin)
            % Plots 3D object using sliceomatic with the view straight down one
            % of the axes.
            varargout = throw_unavailable_(w,'sliceomatic_overview', varargin{:});
        end
    end
    
    
    %---------------------------------------------------------------------------
    % Static methods
    %---------------------------------------------------------------------------
    methods(Static)
        %-----------------------------------------------------------------------
        % Static utility methods
        %
        % They are defined as static methods rather than utility functions so
        % that there is no danger whatever of a method of the first argument
        % being called, with all the possible hard to track errors that may
        % occur.
        %-----------------------------------------------------------------------
        function stored_name = default_name (name)
            % Set the default name for a figure
            %
            % Set the name:
            %   >> default_name (figure_name)  % set the name
            %   >> default_name ()             % set to null
            %   >> default_name ([])           % equivalent syntax to set to null
            %
            % Retrieve the name:
            %   >> stored_figure_name = default_name()
            %
            % This is a utility method for use inside the plot interface for
            % data classes other than those for IX_dataset_1d, _2d, _3D ...
            %
            % Use this function to set the name for a genie_figure different to
            % the built-in defaults for the different plot types for a
            % (one-dimensional, area plot, surface plot etc.) before calling the
            % respective IX_dataset_*d plotting function (de, pl, da etc.) in
            % the data class.
            %
            % It needs to be a static method as it will be used in all plotting
            % methods that want to set a figure name that is not the built-in
            % default name.
            %
            % Input:
            % ------
            %   name            Default name to be used for figures
            %                   Note:
            %                   - The empty character vector '' is a valid name.
            %                   - If the figure name is not given, or is [], the
            %                     default is set to the null name, which
            %                     indicates that the hard-wired defaults for the
            %                     different plot types (one-dimensional, area
            %                     plot, surface plot etc.) will be used.                   
            %
            % Output:
            % -------
            %   stored_name     Stored default name (character vector).
            %                   If the name has been set to null, then
            %                   stored_name is set to [].
            
            persistent store
            
            if nargout==0
                if nargin==0 || (isnumeric(name) && isempty(name))
                    store = [];
                elseif is_string(name)
                    store = strtrim(name);  % strip leading and trailing whitespace
                else
                    error('HERBERT:data_plot_interface:invalid_argument', ...
                        'The default name can only be set to a character vector')
                end
            elseif nargout>0
                if nargin==0
                    % Return stored name
                    stored_name = store;
                else
                    error('HERBERT:data_plot_interface:invalid_argument', ...
                        'Cannot have both input and output arguments')
                end
            end 
        end
    end
    %---------------------------------------------------------------------------
end


%---------------------------------------------------------------------------
% Utility functions
%---------------------------------------------------------------------------
function varargout = throw_unavailable_(obj, method, varargin)
% Throw method unavailable
varargout = cell(1, nargout);   % output only if requested
error(['HORACE:',class(obj),':invalid_argument'],...
    'Method ''%s'' is not available for objects of class ''%s''', ...
    method, class(obj))
end
