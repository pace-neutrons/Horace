classdef genieplot < handle
    % Singleton class to hold the state of genie_figure graphics.
    %
    % This is a simple implementation of a singleton. It permits the setting
    % and getting of values. This can be done in two ways:
    %
    % - Follow a standard syntax implemented in Horace in numerous places, where
    %   an instance of a pointer to the singleton is created, and the properties
    %   are retrived or changed for that instance (and all others) using the
    %   usual Matlab object syntax:
    %       <object>.<property> = <value>
    %       <value> = <object>.<property>
    %
    % - Set or get property values using the same syntax as the original Matlab
    %   graphics object properties, namely:
    %       <object>.set(<name>, <value>)
    %       <value> = <object>.get(<name>)
    %   thereby being consistent with matlab graphics property setting/getting.
    %
    % The two syntaxes can be used together. In more detail:
    %
    % Use: standard method
    % --------------------
    % Get an instance pointing to the genieplot singleton:
    %   >> g = genieplot.instance();
    %
    % To set a property:
    %   >> g.<property_name> = <value>;
    %
    %   EXAMPLE: >> g.colors = {'b','r','g'};
    %
    % To retrieve a property:
    %   >> <value> = g.<property_name>;
    %
    %   EXAMPLE: >> val = g.marker_sizes
    %            val =
    %                 6
    %
    % List the names and values of all properties:
    %   >> g
    %
    % To reset all properties to the defaults:
    %   >> g.reset()
    %
    %
    % Use: set and get syntax directly on the singleton
    % -------------------------------------------------
    % To set a property:
    %   >> genieplot.set(<property_name>, <value>)
    %
    %   EXAMPLE: >> genieplot.set('colors', {'b','r','g'})
    %
    % To retrieve a property:
    %   >> value = genieplot.get(<property_name>)
    %
    %   EXAMPLE: >> val = genieplot.get('marker_sizes')
    %            val =
    %                 6
    %
    % Get a structure with all properties:
    %   >> S = genieplot.get()
    %
    % Set all properties from a structure:
    %   >> genieplot.set(S)
    %
    % To reset all properties to the defaults:
    %   >> genieplot.reset
    %
    %
    % Example of mixed use
    % --------------------
    % The two syntaxes can be intermixed. For example:
    %   >> a = genieplot.instance();    % get an instance of the singleton
    %   >> b = genieplot.instance();    % get a second instance
    %   >> a.colors = {'b', 'g', 'r'};  % set the colors with instance a
    %   >> bcol = b.colors              % confirm colors have changed for b too
    %
    %   bcol =
    %
    %     1×3 cell array
    %
    %       {'b'}    {'g'}    {'r'}
    %
    %   >> genieplot.reset()        % set all properties to the default values
    %   >> bcol = b.colors          % confirm they have changed for b too
    %
    %   bcol =
    %
    %     1×1 cell array
    %
    %       {'k'}
    %
    %   >> genieplot.set('colors', {'g', 'k'})  % change colors directly
    %   >> bcol = b.colors              % confirm they have changed for b too
    %
    %   bcol =
    %
    %     1×2 cell array
    %
    %       {'g'}    {'k'}


    % NOTES FOR DEVELOPERS
    % --------------------
    % - The reset method resets all properties to the default values, but is not
    % the same as clearing a variable. Here, reset is simply a method that is
    % equivalent to issuing the set command for every property with the
    % corresponding default value.
    %
    % - As currently implemented, if all instances as created by
    %       >> a = genieplot.instance()
    %       >> b = genieplot.instance()
    %               :
    % are cleared using the Matlab method
    %       >> clear a b ...
    %
    % then this has no effect on the underlying singleton values. That is, if an
    % instance is created afterwards
    %       >> c = genieplot.instance()
    %
    % the values of the properties are those that a, b, ... had at the time that
    % the clear command was issued.


    properties(Dependent)
        % The properties that can be publically accessed.

        % General graph properties
        default_fig_name    % default name for plot
        XScale              % x-axis scaling: 'linear' or 'log'
        YScale              % y-axis scaling: 'linear' or 'log'
        ZScale              % z-axis scaling: 'linear' or 'log'

        % One-dimensional graph properties
        maxspec_1D          % Maximum number of 1D datasets in a plottable array
        colors              % Row cell array of default colors
        color_cycle         % 'fast' or 'with': colours cycle faster or with
        % line styles & widths and marker types & sizes
        line_styles         % Row cell array of default line styles
        line_widths         % Row vector of default line widths
        marker_types        % Row cell array of default marker types
        marker_sizes        % Row vector of default marker sizes

        % Two-dimensional graph properties
        maxspec_2D          % Maximum number of 2D datasets in a plottable array

        % matlab 2025 introduced new colour scheme, which, if windows
        % scheme is dark makes Horace graphics unusable. If this option is
        % true, Horace reverts to the colour scheme used by Matlab 2024b
        % and before
        use_original_horace_plot_colours
    end

    properties(Access=private)
        % These properties are exact mirrors of the dependent properties
        % See dependent properties for descriptions.
        %
        % In general the public properties need not be the same as the
        % properties that hold the state of the object (although in this simple
        % example they are). We implement this by having private proprties and
        % public dependent properties.

        % General graph properties
        default_fig_name_
        XScale_
        YScale_
        ZScale_

        % One-dimensional graph properties
        maxspec_1D_
        colors_
        color_cycle_
        line_styles_
        line_widths_
        marker_types_
        marker_sizes_

        % Two-dimensional graph properties
        maxspec_2D_

        use_original_horace_plot_colours_
    end

    methods (Access=private)
        % The constructor is private, preventing external invocation.
        % Only a single instance of this class is created. This is
        % ensured by genieplot.instance() calling the constructor only once.
        function newObj = genieplot()
            % Initialize by calling a separate function. This function will also
            % be called by the static method named 'reset'
            initialise(newObj)
        end
    end

    methods
        %-----------------------------------------------------------------------
        % Get methods for the public properties
        %-----------------------------------------------------------------------
        % General graph properties
        function val = get.default_fig_name(obj)
            val = obj.default_fig_name_;
        end
        function val = get.XScale(obj)
            val = obj.XScale_;
        end
        function val = get.YScale(obj)
            val = obj.YScale_;
        end
        function val = get.ZScale(obj)
            val = obj.ZScale_;
        end

        % One-dimensional graph properties
        function val = get.maxspec_1D(obj)
            val = obj.maxspec_1D_;
        end
        function val = get.colors(obj)
            val = obj.colors_;
        end
        function val = get.color_cycle(obj)
            val = obj.color_cycle_;
        end
        function val = get.line_styles(obj)
            val = obj.line_styles_;
        end
        function val = get.line_widths(obj)
            val = obj.line_widths_;
        end
        function val = get.marker_types(obj)
            val = obj.marker_types_;
        end
        function val = get.marker_sizes(obj)
            val = obj.marker_sizes_;
        end

        % Two-dimensional graph properties
        function val = get.maxspec_2D(obj)
            val = obj.maxspec_2D_;
        end

        function do_use = get.use_original_horace_plot_colours(obj)
            do_use = obj.use_original_horace_plot_colours_;
        end
    end

    methods
        %-----------------------------------------------------------------------
        % Check validity of properties on setting
        %-----------------------------------------------------------------------
        function set.default_fig_name(obj, val)
            % The default name for a genie figure.
            % - The empty character vector '' is a valid name.
            % - If the figure name is [], this means that the hard-wired value
            %   for the relevant plot type will be used (one-dimensional plot,
            %   area plot, surface plot etc.).
            if is_string(val)
                % Strip leading and trailing whitespace
                obj.default_fig_name_ = strtrim(val);
            elseif isnumeric(val) && isempty(val)
                obj.default_fig_name_ = [];
            else
                error('HERBERT:genieplot:invalid_argument', ['The default ', ...
                    'name can only be set to a character vector or []']);
            end
        end
        %-----------------------------------------------------------------------
        function set.XScale(obj, val)
            if is_string(val) && any(strcmp(val, {'linear', 'log'}))
                obj.XScale_ = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'XScale must be ''linear'' or ''log''');
            end
        end
        %-----------------------------------------------------------------------
        function set.YScale(obj, val)
            if is_string(val) && any(strcmp(val, {'linear', 'log'}))
                obj.YScale_ = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'YScale must be ''linear'' or ''log''');
            end
        end
        %-----------------------------------------------------------------------
        function set.ZScale(obj, val)
            if is_string(val) && any(strcmp(val, {'linear', 'log'}))
                obj.ZScale_ = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'ZScale must be ''linear'' or ''log''');
            end
        end
        %-----------------------------------------------------------------------
        function set.maxspec_1D(obj, val)
            if isnumeric(val) && isscalar(val) && val>0 && (isinf(val) || ...
                    (isfinite(val) && rem(val,1)==0))
                obj.maxspec_1D_ = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'maxspec_1D must be a positive integer or Inf');
            end
        end
        %-----------------------------------------------------------------------
        function set.colors(obj, val)
            % Property 'colors' must be a cell array with elements that are each
            % either one of the valid color codes or a valid hexadecimal color
            % code
            colorCodes = {'r','g','b','c','m','y','k','w'}; % Valid color codes

            nonEmptyString = @(x)(is_string(x) && ~isempty(x));
            isColorCode = @(x)(any(strcmp(x, colorCodes)) || ishexcolor(x));
            if iscell(val) && all(cellfun(nonEmptyString, val(:))) && ...
                    all(cellfun(isColorCode, val(:)))
                obj.colors_ = val(:)';   % ensure a row cell array
            else
                error('HERBERT:genieplot:invalid_argument', ['colors must be a ', ...
                    'cell array with elements from ''r'',''g'',''b'',''c'',''m'',', ...
                    '''y'',''k'',''w''\nor a valid hexadecimal of the form ''#rrggbb''']);
            end
        end
        %-----------------------------------------------------------------------
        function set.line_styles(obj, val)
            % line_styles must a cell array with elements from the valid Matlab
            % types:
            %       '-',  '--',  ':',  '-.'
            line_style_codes = {'-',  '--',  ':',  '-.'};
            if (is_string(val) && any(strcmp(val, line_style_codes)))
                obj.line_styles_ = val;
            elseif iscell(val) && all(cellfun(@is_string, val(:))) && ...
                    all(ismember(val(:), line_style_codes))
                obj.line_styles_ = val(:)';  % ensure a row cell array
            else
                error('HERBERT:genieplot:invalid_argument', ['''line_styles ''', ...
                    'must be a cell array with elements one of ', ...
                    '''-'',  ''--'',  '':'',  ''-.''']);
            end
        end
        %-----------------------------------------------------------------------
        function set.line_widths(obj, val)
            % line_widths must be a row vector of reals greater than zero
            if isnumeric(val) && all(isfinite(val(:))) && all(val(:)>0)
                obj.line_widths_ = val(:)';  % ensure a row vector
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    '''line_widths'' must be reals greater than zero');
            end
        end
        %-----------------------------------------------------------------------
        function set.marker_types(obj, val)
            % line_styles must a cell array with elements from the valid Matlab
            % types:
            %     {'o','+','*','.','x','_','|','s','d','^','v','>','<','p','h'}
            if verLessThan('MATLAB','9.9')  % prior to R2020b
                marker_type_codes = ...
                    {'o','+','*','.','x','s','d','^','v','>','<','p','h'};
            else
                marker_type_codes = ...
                    {'o','+','*','.','x','_','|','s','d','^','v','>','<','p','h'};
            end
            if (is_string(val) && any(strcmp(val, marker_type_codes)))
                obj.marker_types_ = val;
            elseif iscell(val) && all(cellfun(@is_string, val(:))) && ...
                    all(ismember(val(:), marker_type_codes))
                obj.marker_types_ = val(:)';  % ensure a row cell array
            else
                error('HERBERT:genieplot:invalid_argument', ['''marker_types ''', ...
                    'must be a cell array of valid marker types for your ', ...
                    'matlab version']);
            end
        end
        %-----------------------------------------------------------------------
        function set.marker_sizes(obj, val)
            % marker_sizes must be a row vector of reals greater than zero
            if isnumeric(val) && all(isfinite(val(:))) && all(val(:)>0)
                obj.marker_sizes_ = val(:)';     % ensure a row vector
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    '''marker_sizes'' must be reals greater than zero');
            end
        end
        %-----------------------------------------------------------------------
        function set.color_cycle(obj, val)
            % Must be one of 'fast' or 'with'
            if is_string(val) && any(strcmpi(deblank(val), {'fast','with'}))
                obj.color_cycle_ = deblank(val);
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    '''marker_sizes'' must be reals greater than zero');
            end
        end
        %-----------------------------------------------------------------------
        function set.maxspec_2D(obj, val)
            if isnumeric(val) && isscalar(val) && val>0 && (isinf(val) || ...
                    (isfinite(val) && rem(val,1)==0))
                obj.maxspec_2D_ = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'maxspec_2D must be a positive integer or Inf');
            end
        end
        %-----------------------------------------------------------------------
        function set.use_original_horace_plot_colours(obj,val)
            obj.use_original_horace_plot_colours_ = logical(val);
            if obj.use_original_horace_plot_colours_
                theme('light')
            else
                theme('auto')
            end
        end
    end

    %---------------------------------------------------------------------------
    % No need to touch below this line

    methods (Static)
        function obj = instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = genieplot();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end

        function set(property, newData)
            % Set a single property, or set all properties from a structure
            obj = genieplot.instance();
            if ~isstruct(property)
                obj.(property) = newData;
            else
                % Set properties from a structure. The structure must have all
                % and only fieldnames corresponding to properties of genieplot.
                S = genieplot.get();    % store current properties
                try
                    names = fieldnames(property);
                    for i = 1:numel(names)
                        obj.(names{i}) = property.(names{i});
                    end
                catch ME
                    genieplot.set(S);   % recover incoming settings
                    rethrow(ME)
                end
            end
        end

        function data = get(property)
            % Get a single property, or a structure with all properties
            obj = genieplot.instance();
            if nargin>0
                data = obj.(property);
            else
                % Fill a structure with all the properties
                names = properties(obj);
                for i = 1:numel(names)
                    data.(names{i}) = obj.(names{i});
                end
                data = orderfields(data);
            end
        end

        function reset()
            % Set the singleton properties back to their default values
            obj = genieplot.instance();
            initialise(obj);
        end
    end

end


%-------------------------------------------------------------------------------
function initialise(obj)
% Function to set default values of the private properties

obj.default_fig_name_ = []; % default name for plot

obj.XScale_ = 'linear';     % x-axis scaling: 'linear' or 'log'
obj.YScale_ = 'linear';     % y-axis scaling: 'linear' or 'log'
obj.ZScale_ = 'linear';     % z-axis scaling: 'linear' or 'log'

obj.maxspec_1D_ = 1000;     % Maximum number of 1D datasets in a plottable array
obj.colors_ = {'k'};        % Row cell array of default colors
obj.color_cycle_ = 'with';  % 'fast' or 'with': colours cycle faster or with
obj.line_styles_ = {'-'};   % Row cell array of default line styles
obj.line_widths_ = 0.5;     % Row vector of default line widths
obj.marker_types_ = {'o'};  % Row cell array of default marker types
obj.marker_sizes_ = 6;      % Row vector of default marker sizes

obj.maxspec_2D_ = 1000;     % Maximum number of 2D datasets in a plottable array

% use standard Horace colour scheme for graphics
obj.use_original_horace_plot_colours_ = true;
theme('light');
end


%-------------------------------------------------------------------------------
function status = ishexcolor(str)
% Determine is a character vectors has the form '#rrggbb' with each character
% pair being a hexadecimal in the range 0 to 255
if is_string(str) && numel(str)==7 && str(1:1)=='#'
    try
        R = hex2dec(str(2:3));
        G = hex2dec(str(4:5));
        B = hex2dec(str(6:7));
        if all([R,G,B]>=0 & [R,G,B]<=255)
            status = true;
        end
    catch
        status = false;
    end
    return
end
status = false;
end
