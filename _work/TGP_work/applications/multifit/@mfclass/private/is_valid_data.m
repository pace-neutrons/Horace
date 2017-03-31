function [ok, mess, ndim, wout] = is_valid_data (class_name, varargin)
% Check nature and validity of data type(s) to be fitted, and repackage in a standard form.
%
%   >> [ok, mess, ndim, wout] = is_valid_data                 % No data sets
%   >> [ok, mess, ndim, wout] = is_valid_data (class_name, x, y, e)
%   >> [ok, mess, ndim, wout] = is_valid_data (class_name, w1, w2, ...)
%
% Input:
% ------
%   class_name  Name of class of objects. If blank, then generic input types
%               are allowed; if given, then all data must be objects of this class.
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
%   ok              Status flag: =true if each element of argument w satisfies one of
%                  the above formats; =false otherwise (the elements of w do not need
%                  to all have the same format)
%
%   mess            Error message: ='' if OK, contains error message if not OK.
%
%   ndim            Cell array (row vector) of numeric arrays. If the input
%                  data sets are w1, w2, ... then
%                       size(ndim{i}) = size(wi)
%                  and ndim{i} is the array of the number of dimensions of each
%                  datasets in wi, if wi is a cell array of xye triples or a
%                  structure array. If wi is an object array, then ndim{i} is
%                  filled with NaNs.
%                   If the input data was x,y,e then ndim{1} is scalar, as
%                  there is just one dataset.
%
%                   If not ok, ndim=cell(1,0)
%
%   wout            Cell array of datasets (row) that contain repackaged data:
%                  every entry is either
%                   - an x-y-e triple with wout{i}.x a cell array of arrays,
%                     one for each x-coordinate,
%                   - a scalar object
%
%                   If not ok, wout=cell(1,0)


narg=numel(varargin);
if narg>0
    if isempty(class_name)
        % Generic data types allowed
        if narg==3 && isnumeric(varargin{2}) && isnumeric(varargin{3})
            % Check for possibility that there are three arguments x,y,e
            ndim=cell(1,1);
            [ok,mess,ndim{1},wout] = is_cell_xye(varargin);
        else
            % General case
            ndim=cell(1,narg);
            wout=cell(1,narg);
            for i=1:narg
                if iscell(varargin{i})
                    [ok,mess,ndim{i},wout{i}] = is_cell_xye (varargin{i});
                    if ~ok
                        mess=['Cell array data: ',mess];
                        break
                    end
                elseif isstruct(varargin{i})
                    [ok,mess,ndim{i},wout{i}] = is_struct_xye (varargin{i});
                    if ~ok
                        mess=['Structure data: ',mess];
                        break
                    end
                elseif isobject(varargin{i})
                    [ok,mess,ndim{i},wout{i}] = is_object_xye (varargin{i});
                    if ~ok
                        mess=['Object array data: ',mess];
                        break
                    end
                else
                    ok=false;
                    mess='Unrecognised dataset format';
                    break
                end
            end
            if ok
                wout=horzcat(wout{:});
            else
                if narg>1, mess=['Data argument ',num2str(i),': ',mess]; end
            end
        end
    else
        % Specific class required
        if all(cellfun(@(x)isa(x,class_name),varargin))
            ndim=cell(1,narg);
            wout=cell(1,narg);
            for i=1:narg
                [ok,mess,ndim{i},wout{i}] = is_object_xye (varargin{i});
                if ~ok
                    mess=['Object array data: ',mess];
                    break
                end
            end
            if ok
                wout=horzcat(wout{:});
            else
                if narg>1, mess=['Data argument ',num2str(i),': ',mess]; end
            end
        else
            ok=false;
            mess=['Data set(s) must all be object(s) of class ''',class_name,''''];
        end
    end
    if ~ok
        ndim=cell(1,0);
        wout=cell(1,0);
    end
else
    ok=true;
    mess='';
    ndim=cell(1,0);
    wout=cell(1,0);
end


%--------------------------------------------------------------------------------------------------
function [ok,mess,ndim,wout] = is_cell_xye(w)
% Determine if an argument is a cell array with valid fields x, y, e
%
%   >> [ok,mess,ndim] = is_cell_xye (w)
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
%   ok      Status flag: =true if each element of argument w satisfies one of
%          the above formats; =false otherwise (the elements of w do not need
%          to all have the same format)
%
%   mess    Error message: ='' if OK, contains error message if not OK.
%
%   ndim    Array with size equal to that of w with the dimensionality of
%          each of the data sets.
%           If not ok, then ndim=NaN(size(w))
%
%   wout    Cell array (row) of stuctures each with fields x,y,e
%          where wout{i}.x is a cell array of arrays, one element for each x
%          coordinate.
%           If not ok, then still a row cell array with one structure in each
%          element

if numel(w)>0 && all(make_column(cellfun(@iscell,w))) && all(make_column(cellfun(@numel,w))==3)
    % w is non-empty and all elements of w are cell arrays length 3
    ok = true;
    mess = '';
    ndim=NaN(size(w));
    wout=cell(1,numel(w));
    for i=1:numel(w)
        tmp.x=w{i}{1}; tmp.y=w{i}{2}; tmp.e=w{i}{3};
        [ok,mess,ndim(i),wout(i)] = is_struct_xye (tmp);
        if ~ok, return, end
    end
    
elseif numel(w)==3
    % Three elements, not all cell arrays
    tmp.x=w{1}; tmp.y=w{2}; tmp.e=w{3};
    [ok,mess,ndim,wout] = is_struct_xye (tmp);
    if ~ok, return, end
    
else
    ok=false;
    mess='Data must have form {x,y,e} or {{x1,y1,e1}, {x2,y2,e2},...}';
    ndim=NaN(size(w));
    wout=w(:)';
    
end


%--------------------------------------------------------------------------------------------------
function [ok,mess,ndim,wout] = is_struct_xye (w)
% Determine if an argument is structure array with valid fields x,y,e
%
%   >> [ok,mess,ndim] = is_struct_xye (w)
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
%   ok      Status flag: =true if each element of argument w satisfies one of
%          the above formats; =false otherwise (the elements of w do not need
%          to all have the same format)
%
%   mess    Error message: ='' if OK, contains error message if not OK.
%
%   ndim    Array with size equal to that of w with the dimensionality of
%          each of the data sets.
%           If not ok, then ndim=NaN(size(w))
%
%   wout    Cell array (row) of stuctures each with fields x,y,e
%          where wout{i}.x is a cell array of arrays, one element for each x
%          coordinate.
%           If not ok, then still a row cell array with one structure in each
%          element

ok=false;
ndim=NaN(size(w));
wout=num2cell(w(:)');

% Catch case of empty structure
if numel(w)==0
    mess='empty structure';
    return
end

% General case
for i=1:numel(w)
    if ~all(isfield(w(i),{'x','y','e'}))
        mess=[message_opening(w,i),'does not have fields ''x'',''y'' and ''e'''];
        return
    end
    if ~(isnumeric(w(i).y) && isnumeric(w(i).e))
        mess=[message_opening(w,i),'signal and error arrays are not numeric'];
        return
    elseif isempty(w(i).y) || isempty(w(i).e)
        mess=[message_opening(w,i),'signal and/or error array is empty'];
        return
    else
        szy=size(w(i).y);
        if ~isequal(szy,size(w(i).e))
            mess=[message_opening(w,i),'signal and error arrays are not same size'];
            return
        end
    end
    if isnumeric(w(i).x) && isnumeric(w(i).y) && isnumeric(w(i).e)
        if isempty(w(i).x)
            mess=[message_opening(w,i),'x-coordinate array is empty'];
            return
        end
        sz=size(w(i).x);
        if ~isequal(sz,szy)
            if numel(szy)==2 && szy(2)==1, szy=szy(1); end   % y array is a column vector, so strip the redundant outer dimension
            if ~isequal(sz(1:end-1),szy)
                mess=[message_opening(w,i),'signal and error array sizes do not match coordinate array size'];
                return
            end
            ndim(i)=sz(end);
            wout{i}.x=num2cell(w(i).x,1:ndim(i)-1); % separate the dimensions into cells
        else
            ndim(i)=1;
            wout{i}.x={w(i).x};     % make a cell array with a single element
        end
    elseif iscell(w(i).x)
        if isempty(w(i).x)
            mess=[message_opening(w,i),'cell array of x-coordinates is empty'];
            return
        end
        sz=size(w(i).x{1});
        for j=1:numel(w(i).x)
            if ~isnumeric(w(i).x{j})
                mess=[message_opening(w,i),'cell array of x-coordinate array(s) not all numeric'];
                return
            elseif ~isequal(sz,size(w(i).x{j}))
                mess=[message_opening(w,i),'cell array of x-coordinates array(s) not all same size'];
                return
            elseif isempty(w(i).x{j})
                mess=[message_opening(w,i),'cell array of x-coordinates array(s) has at least one empty array'];
                return
            end
        end
        if ~isequal(sz,szy)
            mess=[message_opening(w,i),'signal and error array sizes do not match coordinate array(s) size'];
            return
        end
        ndim(i)=numel(w(i).x);
    else
        mess=[message_opening(w,i),'x-coordinate must be a numeric array or cell array of numeric arrays'];
        return
    end
end
ok=true;
mess='';


function str = message_opening(w,i)
% Create opening part of error message
if numel(w)>1
    str=['array element ',arraystr(size(w),i)];
else
    str='';
end


%--------------------------------------------------------------------------------------------------
function [ok,mess,ndim,wout] = is_object_xye (w)
% Determine if argument is an object array with valid methods for fitting
%
%   >> [ok,mess,ndim,wout] = is_object_xye (w)
%
% Input:
% ------
%   w       Array of objects
%
% Output:
% -------
%   ok      Status flag: =true if each element of argument w satisfies one of
%          the above formats; =false otherwise (the elements of w do not need
%          to all have the same format)
%
%   mess    Error message: ='' if OK, contains error message if not OK.
%
%   ndim    Array with size equal to that of w with the dimensionality of
%          each of the data sets.
%           If not ok, then ndim=NaN(size(w))
%
%   wout    Cell array (row) of stuctures each with fields x,y,e
%          where wout{i}.x is a cell array of arrays, one element for each x
%          coordinate.
%           If not ok, then still a row cell array with one structure in each
%          element

ndim=NaN(size(w));
wout=num2cell(w(:)');

% Catch case of empty structure
if numel(w)==0
    ok=false;
    mess='empty object';
    return
end

% General case
meth=methods(w);
methreq={'sigvar_get';'plus';'mask';'sigvar_getx';'mask_points'};
status=ismember(methreq,meth);
if all(status(1:3)) && any(status(4:5))
    ok=true;
    mess='';
else
    ok=false;
    mess='Data object must have methods ''sigvar_get'',''plus'',''mask'' and either ''sigvar_getx'' or ''mask_points''';
end
