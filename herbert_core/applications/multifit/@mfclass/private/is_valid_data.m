function wout = is_valid_data (class_name, varargin)
% Check nature and validity of data type(s) to be fitted, and repackage in a standard form.
%
%   >> wout = is_valid_data (class_name)                % No data sets
%   >> wout = is_valid_data (class_name, [])            % No data sets
%   >> wout = is_valid_data (class_name, x, y, e)
%   >> wout = is_valid_data (class_name, w1, w2, ...)
%
% Input:
% ------
%   class_name  Name of class of objects. If empty, then generic input types
%               are allowed; if not empty, then all data must be objects of
%               this class.
%
%   Data to be fitted:
%
% Arrays x,y,e that describe a single dataset:
%
%       x       Coordinates of the data points:
%               - An array of any size whose outer dimension gives the
%                coordinate dimension i.e. x(:,:,...:,1) is the array of
%                x values along axis 1, x(:,:,...:,2 along axis 2) ...
%                to x(:,:,...:,n) along the nth axis.
%                 The exception is if size(x) matches size(y), then the outer dimension
%                is taken as unity and the data is considered to be one dimensional
%                   e.g. x=[1.1, 2.3, 4.3    &  y=[110, 121, 131
%                           1.7, 5.4, 7.0]         141, 343,  89]
%
%           OR  - A cell array of length n, where x{i} gives the coordinates in the
%                ith dimension for all the data points. The arrays must all have
%                the same size, but there are no restrictions on what that size is.
%
%       y       Array of the data values at the points defined by x. Must
%               have the same same size as x(:,:,...:,1) if x is an array, or
%               of x{i} if x is a cell array.
%
%       e       Array of the corresponding error bars. Must have same size as y.
%
%
% More generally: a series w1, w2, ... of any mixture of the following argument types:
%
%   - Cell array of arrays x, y, e above (defines a single dataset):
%       w = {x,y,e}
%
%     Cell array of cell arrays that defines multiple datasets:
%       w = {{x1,y1,e1}, {x2,y2,e2}, {x3,y3,e3},...}
%
%   - Structure with fields w.x, w.y, w.e  where x, y, e have one of the
%     forms described above (this defines a single dataset)
%
%     Structure array with fields w(i).x, w(i).y, w(i).e (this defines
%     several datasets)
%
%   - Object or array of objects, w
%
%
% Output:
% -------
%   wout            Cell array of datasets (row) that contain repackaged data:
%                  every entry is either
%                   - an x-y-e triple with wout{i}.x a cell array of arrays,
%                     one for each x-coordinate,
%                   - a scalar object
%


% Original author: T.G.Perring


narg=numel(varargin);
if narg==0 || (narg==1 && isnumeric(varargin{1}) && isempty(varargin{1}))
    % No input or a single, empty, item
    wout=cell(1,0);

elseif ~isempty(class_name)
    % Specific class required
    if ~all(cellfun(@(x)isa(x,class_name),varargin))
        error('HERBERT:mfclass:invalid_argument', 'Data set(s) must all be object(s) of class ''%s''', class_name)
    end

    wout=cell(1,narg);
    for i=1:narg
        try
            wout{i} = is_object_xye(varargin{i});
        catch ME
            BE = MException('HERBERT:mfclass:invalid_argument', 'Unable to load dataset %d', i);
            BE = BE.addCause(ME);
            throw(BE)
        end
    end
    wout = horzcat(wout{:});

elseif narg==3 && all(cellfun(@isnumeric, varargin))
    % Check for possibility that there are three arguments x,y,e
    wout = is_cell_xye(varargin);

else
    % General case
    wout=cell(1,narg);
    for i=1:narg
        try
            if iscell(varargin{i})
                wout{i} = is_cell_xye(varargin{i});
            elseif isstruct(varargin{i})
                wout{i} = is_struct_xye(varargin{i});
            elseif isobject(varargin{i})
                wout{i} = is_object_xye(varargin{i});
            else
                error('HERBERT:mfclass:invalid_argument', 'Unrecognised dataset format');
            end
        catch ME
            BE = MException('HERBERT:mfclass:invalid_argument', 'Unable to load dataset %d', i);
            BE = BE.addCause(ME);
            throw(BE)
        end
    end

    wout=horzcat(wout{:});
end

end

function wout = is_cell_xye(w)
% Determine if an argument is a cell array with valid fields x, y, e
%
%   >> [ok,mess,wout] = is_cell_xye (w)
%
% Input:
% ------
%   w       Cell array which has standard form for data required by multifit
%                   {x,y,e}
%               or
%                   {{x1,y1,e1}, {x2,y2,e2}, {x3,y3,e3},...}
%
% Output:
% -------
%   wout    Cell array (row) of stuctures each with fields x,y,e
%          where wout{i}.x is a cell array of arrays, one element for each x
%          coordinate.
%           If not ok, then still a row cell array with one structure in each
%          element

if ~isempty(w) && all(cellfun(@iscell,w)) && all(cellfun(@numel,w) == 3)
    % w is non-empty and all elements of w are cell arrays length 3
    wout=cell(1,numel(w));
    for i=1:numel(w)
        tmp.x=w{i}{1};
        tmp.y=w{i}{2};
        tmp.e=w{i}{3};
        wout(i) = is_struct_xye (tmp);
    end

elseif numel(w)==3
    % Three elements, not all cell arrays
    tmp.x=w{1};
    tmp.y=w{2};
    tmp.e=w{3};
    wout = is_struct_xye (tmp);

else
    error('HERBERT:mfclass:invalid_argument', 'Data must have form {x,y,e} or {{x1,y1,e1}, {x2,y2,e2},...}')
end

end

function wout = is_struct_xye (w)
% Determine if an argument is structure array with valid fields x,y,e
%
%   >> wout = is_struct_xye (w)
%
% Input:
% ------
%   w       Structure array with fields x,y and e, where:
%
%   w(i).x  Coordinates of the data points:
%               - An array of any size whose outer dimension gives the
%                coordinate dimension i.e. x(:,:,...:,1) is the array of
%                x values along axis 1, x(:,:,...:,2 along axis 2) ...
%                to x(:,:,...:,n) along the nth axis.
%                 If size(x) matches size(y), then the outer dimension is taken
%                as unity and the data is considered to be one dimensional
%                   e.g. x=[1.1, 2.3, 4.3    &  y=[110, 121, 131
%                           1.7, 5.4, 7.0]         141, 343,  89]
%
%      OR       - A cell array of length n, where x{i} gives the coordinates in the
%                ith dimension for all the data points. The arrays can have any
%                size, but they must all have the same size.
%
%   w(i).y  Array of the of data values at the points defined by x. Must
%           have the same same size as x(:,:,...:,i) if x is an array, or
%           of x{i} if x is a cell array.
%
%   w(i).e  Array of the corresponding error bars. Must have same size as y.
%
%
% Output:
% -------
%   wout    Cell array (row) of stuctures each with fields x,y,e
%          where wout{i}.x is a cell array of arrays, one element for each x
%          coordinate.
%           If not ok, then still a row cell array with one structure in each
%          element

wout=num2cell(w(:)');

% Catch case of empty structure
assert(~isempty(w), 'HERBERT:mfclass:invalid_argument', 'Provided empty structure');

% General case
for i=1:numel(w)

    szy=size(w(i).y);

    assert(all(isfield(w(i),{'x','y','e'})), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'does not have fields ''x'',''y'' and ''e''']);
    assert(isnumeric(w(i).y) && isnumeric(w(i).e), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'signal and error arrays are not numeric']);
    assert(~isempty(w(i).y) && ~isempty(w(i).e), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'signal and/or error array is empty']);
    assert(isequal(szy,size(w(i).e)), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'signal and error arrays are not same size']);

    if isnumeric(w(i).x) && isnumeric(w(i).y) && isnumeric(w(i).e)
        assert(~isempty(w(i).x), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'x-coordinate array is empty']);

        szx=size(w(i).x);

        if ~isequal(szx,szy)
            if numel(szy) == 2 && szy(2) == 1    % y array is a column vector, so strip the redundant outer dimension
                szy=szy(1);
            end

            assert(isequal(szx(1:end-1),szy), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'signal and error array sizes do not match coordinate array size']);

            %----------------
            % This new code (TGPerring, 20/8/2020)
            wout{i}.x=num2cell(w(i).x,1:numel(szy));    % separate the dimensions into cells
            % replaced:
            %ndim=szx(end);
            %wout{i}.x=num2cell(w(i).x,1:ndim-1); % separate the dimensions into cells
            %----------------
        else
            wout{i}.x={w(i).x};     % make a cell array with a single element
        end
    elseif iscell(w(i).x)
        assert(~isempty(w(i).x), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'cell array of x-coordinates is empty']);
        assert(isequal(szx,szy), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'signal and error array sizes do not match coordinate array(s) size']);

        szx=size(w(i).x{1});

        for j=1:numel(w(i).x)
            assert(isnumeric(w(i).x{j}), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'cell array of x-coordinate array(s) not all numeric']);
            assert(isequal(szx,size(w(i).x{j})), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'cell array of x-coordinates array(s) not all same size']);
            assert(~isempty(w(i).x{j}), 'HERBERT:mfclass:invalid_argument', [message_opening(w,i),'cell array of x-coordinates array(s) has at least one empty array']);
        end

    else
        error('HERBERT:mfclass:invalid_argument', [message_opening(w,i),'x-coordinate must be a numeric array or cell array of numeric arrays']);
    end
end

end

function str = message_opening(w,i)
% Create opening part of error message
if numel(w)>1
    str=['array element ',arraystr(size(w),i)];
else
    str='';
end

end

%--------------------------------------------------------------------------------------------------
function wout = is_object_xye (w)
% Determine if argument is an object array with valid methods for fitting
%
%   >> wout = is_object_xye (w)
%
% Input:
% ------
%   w       Array of objects
%
% Output:
% -------
%   wout    Cell array (row) of stuctures each with fields x,y,e
%          where wout{i}.x is a cell array of arrays, one element for each x
%          coordinate.
%           If not ok, then still a row cell array with one structure in each
%          element

wout=num2cell(w(:)');

% Catch case of empty structure
if isempty(w)
    error('HERBERT:mfclass:invalid_argument', 'Provided empty structure')
end

% General case
meth=methods(w);
methreq={'sigvar_get';'plus';'mask';'sigvar_getx';'mask_points'};
status=ismember(methreq,meth);
if ~all(status(1:3)) && any(status(4:5))
    error('HERBERT:mfclass:invalid_argument', 'Data object must have methods ''sigvar_get'',''plus'',''mask'' and either ''sigvar_getx'' or ''mask_points''');
end

end
