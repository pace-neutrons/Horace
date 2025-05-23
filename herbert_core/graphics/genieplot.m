classdef genieplot < handle
    % Singleton class to hold configuration of graphics options.
    % This is a very lean implementation of a singleton. It permits the setting
    % and getting of values but without any checks on values.
    % 
    % In addition to the standard signleon interface, which requests
    % calling genieplot.instance() for reading and changing the class 
    % properties, it has genieplot specific interface, reminicent of old
    % genie graphics.
    %
    % Use:
    % ----
    % To set a property
    %   >> genieplot.set(<property_name>, <value>)
    %
    %   EXAMPLE: >> genieplot.set('colors',{'b','r','g'})
    %
    % To retrieve a property:
    %   >> value = genieplot.get(<property_name>)
    %
    %   EXAMPLE: >> val = genieplot.get('marker_sizes')
    %           val =
    %                6
    %
    % Get a structure with all properties:
    %   >> S = genieplot.get()
    %
    % Set all properties from a structure:
    %   >> genieplot.set(S)
    %
    % To reset all properties to the defaults
    %   >> genieplot.reset
    %
    % This singleton class is only expected to be used by the graphics
    % functions. Ideally, we would not have it visible to users.

    properties(Dependent)
        % General graph properties
        default_fig_name
        XScale
        YScale
        ZScale

        % One-dimensional graph properties
        maxspec_1D
        colors
        color_cycle
        line_styles
        line_widths
        marker_types
        marker_sizes

        % Two-dimensional graph properties
        maxspec_2D
    end

    properties(Access=private)
        % General graph properties
        default_fig_name_ = []
        XScale_ = 'linear'
        YScale_ = 'linear'
        ZScale_ = 'linear'

        % One-dimensional graph properties
        maxspec_1D_ = 1000 % Maximum number of 1D datasets in a plottable array
        colors_     =  {'k'};
        color_cycle_= 'with'
        line_styles_= {'-'}
        line_widths_= 0.5
        marker_types_ = {'o'};   % Row cell array of default marker types
        marker_sizes_ =  6;       % Row vector of default marker sizes

        % Two-dimensional graph properties
        maxspec_2D_ = 1000;      % Maximum number of 2D datasets in a plottable array
    end

    methods (Access=private)
        % The constructor is private, preventing external invocation.
        % Only a single instance of this class is created. This is
        % ensured by genieplot.instance() calling the constructor only once.
        function newObj = genieplot()
        end
    end
    methods
        % Simple accessors
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
    end

    methods
        %-----------------------------------------------------------------------
        % Check validity of properties on setting
        %-----------------------------------------------------------------------
        function set.default_fig_name(obj, val)
            % The default name for a genie figure.
            % - The empty character vector '' is a valid name.
            % - If the figure name is [], this means that the default is to be
            %   set to hard-wired values for the different plot types (one-
            %   dimensional, area plot, surface plot etc.) will be used.
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
            % Property 'colors' must be a cell arry with elements that either
            % one of the valid color codes or a valid hexadecimal color code
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
    end

    %---------------------------------------------------------------------------
    % No need to touch below this line

    methods (Static)
        function obj = instance(varargin)
            % if any argument is provided to instance, it is assumed that
            % you want to clear its current state (run reset to defaults)
            persistent uniqueInstance
            if isempty(uniqueInstance) || nargin>0
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
            genieplot.instance('clear');
        end
    end

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
