function w2_out = check_data_size (w1, w2, w1_data_name, w2_data_name)
% Check the consistency of the data array sizes of primary and secondary data.
%
%   >> [ok, mess] = check_color_data_size (w1, w2, w1_data_name, w2_data_name)
%
% The primary data is extracted fromm w1 using a method called sigvar, that
% extracts signal and variance arrays. w1 can be a single object or an array of
% objects.
%
% The secondary data is similarly extracted from w2, which is an object or
% object array with the same number of objects as there are in w1.
% Alternativevly, w2 can be a numerical array  or a cell array of numerical
% arrays, with the number of numerical arrays matching the number of objects in
% w1.
%
% Input:
% ------
%   w1          Primary data object or array of data objects.
%                EXAMPLE: The signal of w1 might the z-data for a surface plot.
%
%   w2          Second set of data to check for consistency of number of data
%               objects and sizes against the primary dataset w1.
%                   - An object or array of objects with a method sigvar that
%                     returns signal and variance arrays. The number of objects
%                     must match the number of objects in w1, and the signal
%                     array sizes must match those of the corresponding objects
%                     in w1.
%                   - Numeric array or cell array of numeric arrays that give
%                     the color data.
%
%                EXAMPLE: With plot type 'surface2' independent z-data and color
%                   data is an option:
%                   - The standard errors in w1 provide that color data if w2
%                     is empty.
%                   - A second input data argument w2 provides that data, if
%                     w2 is not empty;    
%
%   w1_data_name  Name of primary data for error messages e.g. 'z-data'
%
%   w2_data_name  Name of secondary data for error messages e.g. 'color data'
%
%
% Output:
% -------
%   w2_out      Secondry data
%               - If none present: set to []
%               - If some present: w2_out = w2


% Determine if there is any secondary data present, and react accordingly if not
if ~(isobject(w2) || iscell(w2) || isnumeric(w2))
    error('HERBERT:graphics:invalid_argument', ...
        ['The object or object array supplying %s is not one of the valid ', ...
        'types:\nobject array, cell array or numeric array'], w2_data_name)
elseif isempty(w2)
    w2_out = [];    % Empty data of one of the permitted types
    return
end

% Non-empty secondary is data present of one of the permitted classes
if isobject(w2) || (iscell(w2) && all(cellfun(@isnumeric, w2(:))))
    % w2 is an array of objects or a cell array of numeric arrays
    % The two data sources w1 and w2 must have the same number of elements
    if numel(w2)~=numel(w1)
        error('HERBERT:graphics:invalid_argument', ...
            ['The number of objects supplying %s must match the number ', ...
            'of objects supplying %s'], w2_data_name, w1_data_name)
    end
    if isobject(w2)
        % Array of objects of non-numeric type. They need to be able to return a
        % signal and error array using a method called sigvar
        if ~ismethod(w1, 'sigvar')
            error('HERBERT:graphics:invalid_argument', ...
                ['The object or object array supplying %s not ', ...
                'have a method called sigvar'], w2_data_name)
        end
        szcol = arrayfun(@get_size, w2, 'UniformOutput', false);
    else
        % Cell array of numeric arrays
        szcol = cellfun(@get_size, w2, 'UniformOutput', false);
    end
    
elseif isnumeric(w2) && numel(w1)==1
    szcol = {size(w2)};   % size in a cell array for consistency with other cases
    
else
    error('HERBERT:graphics:invalid_argument', ...
        ['The %s must be given by an array of objects or a ', ...
        '(cell array of) numeric array(s)'], w2_data_name)
end

% Check that the data sizes match
sz = arrayfun(@get_size, w1, 'UniformOutput', false);    % cell array of array sizes
ok = cellfun(@(x,y)(numel(x)==numel(y) && all(x==y)), sz(:), szcol(:));
if ~all(ok)
    error('HERBERT:graphics:invalid_argument', ...
        ['The object(s) supplying %s must produce array(s) with ', ...
        'size matching the corresponding %s arrays'], w2_data_name, w1_data_name)
end

% Fill output argument
w2_out = w2;

%-------------------------------------------------------------------------------
function sz = get_size(w)
% Get the size of the array containing signal
% Requires a method called sigvar to extract the signal and variance of the
% object.
tmp = sigvar(w);
sz = size(tmp.s);
