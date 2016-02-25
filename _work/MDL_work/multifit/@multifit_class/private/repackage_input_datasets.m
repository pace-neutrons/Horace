function [ok, mess, wout, single_data_arg, cell_data, xye, xye_xarray] = repackage_input_datasets (varargin)
% Check nature and validity of data type(s) to be fitted, and repackage in a standard form.
%
%   >> [ok, mess, w, single_data_arg, cell_data, xye, xye_xarray] = repackage_input_datasets (x, y, e)
%
%   >> [ok, mess, w, single_data_arg, cell_data, xye, xye_xarray] = repackage_input_datasets (win)
%
% Input:
% ------
%   Data to be fitted: 
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
%               have the same same size as x(:,:,...:,i) if x is an array, or
%               of x{i} if x is a cell array.
%
%       e       Array of the corresponding error bars. Must have same size as y.
%   
%   Alternatively:
%       w   - Structure with fields w.x, w.y, w.e  with one of the forms described above
%            (this is a single dataset)
%
%           - Array of structures w(i).x, w(i).y, w(i).e  each with one of the forms
%            described above (this defines several datasets)
%
%           - Cell array of structures, each structure a single dataset
%            (i.e. is a scalar structure)
%
%           - Array of objects
%
%           - Cell array of objects, each object being scalar
%
%           - Cell array of structures or objects, each one corresponding to a
%            single data set
%
% Output:
% -------
%   ok              Status flag: =true if each element of argument w satisfies one of
%                  the above formats; =false otherwise (the elements of w do not need
%                  to all have the same format)
%
%   mess            Error message: ='' if OK, contains error message if not OK.
%
%   wout            Repackaged data: a cell array where each element wout(i) is either
%                    - an x-y-e triple with wout(i).x a cell array of arrays, one for each x-coordinate,
%                    - a scalar object
%
%   single_data_arg Logical scalar: true if single input data argument, false if x,y,e
%
%   cell_data       Logical scalar: true if input data was a cell array
%
%   xye             Logical array, size(w): indicating which data are x-y-e triples (true),
%                  or objects (false)
%
%   xye_xarray      Logical array, size(w): indicates that x values in x-y-e triples
%                  originally formed a single numeric array (true), or was a cell array
%                  with one element for each x-coordinate (false).
%                   Is set to false for data sets that are objects

if numel(varargin)==1
    % Structure array, object array, or cell array
    single_data_arg=true;
    wout=varargin{1};
    if iscell(wout)
        % Any element that is a structure must be a scalar x-y-e triple
        ndim_xye=NaN(size(wout));
        for i=1:numel(wout)
            if isstruct(wout{i})
                if isscalar(wout{i})
                    [ok,mess,ndim_xye(i)]=is_struct_xye(wout{i});
                    if ~ok
                        ok=false;
                        mess=['Data cell array element ',arraystr(size(wout),i),' is a structure : ',mess];
                        wout=[]; single_data_arg=[]; cell_data=[]; xye=[]; xye_xarray=[];
                        return
                    end
                else
                    ok=false;
                    mess=['Data cell array element ',arraystr(size(wout),i),' invalid: it cannot be an array of structures'];
                    wout=[]; single_data_arg=[]; cell_data=[]; xye=[]; xye_xarray=[];
                    return
                end
            elseif ~(isobject(wout{i}) && isscalar(wout{i}))
                ok=false;
                mess=['Data cell array element ',arraystr(size(wout),i),' invalid: it must be a scalar object or structure'];
                wout=[]; single_data_arg=[]; cell_data=[]; xye=[]; xye_xarray=[];
                return
            end
        end
    elseif isstruct(wout)
        % Array of structures permitted, if each element is an x-y-e triple
        [ok,mess,ndim_xye]=is_struct_xye(wout);
        if ~ok
            wout=[]; single_data_arg=[]; cell_data=[]; xye=[]; xye_xarray=[];
            return
        end
    elseif isobject(wout)
        % Could be an array of objects
        ndim_xye=NaN(size(wout));  % NaN to indicate was not an x-y-e triple
    else
        ok=false;
        mess='Data to be fitted does not have one of the permitted formats';
        wout=[]; single_data_arg=[]; cell_data=[]; xye=[]; xye_xarray=[];
        return
    end
    
elseif numel(varargin)==3
    % Could be x-y-e triple, so package as a structure and check validity
    single_data_arg=false;
    wout.x=varargin{1};
    wout.y=varargin{2};
    wout.e=varargin{3};
    [ok,mess,ndim_xye]=is_struct_xye(wout);
    if ~ok
        wout=[]; single_data_arg=[]; cell_data=[]; xye=[]; xye_xarray=[];
        return
    end
    
else
    ok=false;
    mess='Syntax of data argument(s) is invalid';
    wout=[]; single_data_arg=[]; cell_data=[]; xye=[]; xye_xarray=[];
    return
    
end

% Repackage the data in a standard form: a cell array where each element is either
%   - an x-y-e triple with x a cell array of arrays, one for each x-coordinate,
%   - an object.
%
% We do this for three reasons:
%  - do not have to repackage the x in x-y-e triple every time the function is evaluated
%   in the least-squares algorithm
%  - a cell array prevents any confusion with a method of an object
%  - makes the function evaluation algorithm less laden with if...end branches

if ~iscell(wout)
    cell_data=false;  % flag that indicates if input data was not a cell array
    wout=num2cell(wout);
else
    cell_data=true;
end

xye=false(size(wout));     % logical array, true where data is x-y-e triple
xye(isfinite(ndim_xye))=true;
xye_xarray=false(size(wout));
for i=1:numel(wout)
    if xye(i) && ~iscell(wout{i}.x)
        % Input must be a valid xye triple with the x-coords are in a single array
        xye_xarray(i)=true;
        if ndim_xye(i)>1
            wout{i}.x=squeeze(num2cell(wout{i}.x,1:(ndims(wout{i}.x)-1)));    % separate the dimensions into cells
        else
            wout{i}.x={wout{i}.x};    % just make the array a single cell
        end
    end
end

ok=true;
mess='';
