classdef genieplot < handle
    % Singleton class to hold configuration of graphics options
    % This is a very lean implementation of a singleton. It permits the setting
    % and getting of values but without any checks on values
    %
    % Use:
    % ----
    % To set a property
    %   >> genieplot.set(<property_name>, <value>)
    %
    % To retrieve a property:
    %   >> genieplot.get(<property_name>)
    %
    % This singleton class is only expected to be used by the graphics
    % functions. Ideally, we would not have it visible to users.
    
    properties (Access=private)
        XScale = 'linear'
        YScale = 'linear'
        ZScale = 'linear'
        colors = {'k'}          % Row cell array of default colors
        color_cycle = 'with'    % 'fast' or 'with': colours cycle faster or with
                                % line and marker properties in a plot of
                                % dataset arrays
        line_styles = {'-'};    % Row cell array of default line styles
        line_widths = 0.5;      % Row vector of default line widths
        marker_types = {'o'};   % Row cell array of default marker types
        marker_sizes = 6;       % Row vector of default marker sizes
    end
    
    methods (Access=private)
        % The constructor is private, preventing external invocation.
        % Only a single instance of this class is created. This is
        % ensured by getInstance() calling the constructor only once.
        function newObj = genieplot()
            % Initialize here if setting values in the properties block is not
            % feasible
        end
    end
    
    methods
        %-----------------------------------------------------------------------
        % Check validity of properties on setting
        %-----------------------------------------------------------------------
        function set.XScale(obj, val)
            if is_string(val) && any(strcmp(val, {'linear', 'log'}))
                obj.XScale = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'XScale must be ''linear'' or ''log''');
            end
        end
        %-----------------------------------------------------------------------
        function set.YScale(obj, val)
            if is_string(val) && any(strcmp(val, {'linear', 'log'}))
                obj.YScale = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'YScale must be ''linear'' or ''log''');
            end
        end
        %-----------------------------------------------------------------------
        function set.ZScale(obj, val)
            if is_string(val) && any(strcmp(val, {'linear', 'log'}))
                obj.ZScale = val;
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    'ZScale must be ''linear'' or ''log''');
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
                obj.colors = val(:)';   % ensure a row cell array
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
                obj.line_styles = val;
            elseif iscell(val) && all(cellfun(@is_string, val(:))) && ...
                all(ismember(val(:), line_style_codes))
                obj.line_styles = val(:)';  % ensure a row cell array
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
                obj.line_widths = val(:)';  % ensure a row vector
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
                obj.marker_types = val;
            elseif iscell(val) && all(cellfun(@is_string, val(:))) && ...
                all(ismember(val(:), marker_type_codes))
                obj.marker_types = val(:)';  % ensure a row cell array
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
                obj.marker_sizes = val(:)';     % ensure a row vector
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    '''marker_sizes'' must be reals greater than zero');
            end
        end
        %-----------------------------------------------------------------------
        function set.color_cycle(obj, val)
            % Must be one of 'fast' or 'with'
            if is_string(val) && any(strcmpi(deblank(val), {'fast','with'}))
                obj.color_cycle = deblank(val);
            else
                error('HERBERT:genieplot:invalid_argument', ...
                    '''marker_sizes'' must be reals greater than zero');
            end
        end
        %-----------------------------------------------------------------------
    end
        
    %---------------------------------------------------------------------------
    % No need to touch below this line
    
    methods (Static)
        function set(property, newData)
            obj = getInstance();
            obj.(property) = newData;
        end
        
        function data = get(property)
            obj = getInstance();
            if nargin>0
                data = obj.(property);
            else
                % Turn off a warning about heavy-handed use of struct but
                % cleanup to turn back on when exit
                state = warning('query','MATLAB:structOnObject');
                reset_warning = onCleanup(@()warning(state));
                warning('off','MATLAB:structOnObject')
                data = orderfields(structIndep(obj));
            end
        end
    end
    
end

% Note: this is deliberately placed *outside* the class, so that it
% ^^^^  is not exposed to the user. If we do not mind this, we could
%       place getInstance() in the class's static methods group.
function obj = getInstance()
persistent uniqueInstance
if isempty(uniqueInstance)
    obj = genieplot();
    uniqueInstance = obj;
else
    obj = uniqueInstance;
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
