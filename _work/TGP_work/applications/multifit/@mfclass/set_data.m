function obj = set_data(obj,varargin)
% Set data, clearing all data, functions and constraints
%
%   >> obj = obj.set_data ()            % Clears all data
%   >> obj = obj.set_data (w1,w2,...)   % Set objects or arrays of objects
%   >> obj = obj.set_data (x,y,z)       % If valid: set x,y,e, data
%
% More details on data formats are given below below.
%
% The scope of the foreground and background functions as being global or
% local is not altered, even though all data and functions are cleared.
%
% For example, if the foreground was declared as local, it
% will remain so, meaning that one function per data set will be expected
% when the functions are set.
%
% Format of data
% --------------
% Data set(s) are objects: each of w1, w2, ... has the form
%       w       Data object or array of data objects all of the same class
%
% Data set(s) are x-y-e data:
%   - Arrays x,y,e that describe a single dataset:
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
% See also append_data remove_data replace_data

 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$)


% Find optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,~,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end

% Check input data
class_name = obj.wrapfun_.dataset_class;
[ok, mess, ndim, w] = is_valid_data (class_name, args{:});
if ~ok, error(mess), end

% Check optional arguments
[xkeep,xremove,msk,ok,mess] = mask_syntax_valid (numel(w), keyval.keep, keyval.remove, keyval.mask);
if ~ok, error(mess), end

% Create mask arrays
[msk_out,ok,mess] = mask_data (w,[],xkeep,xremove,msk);
if ok && ~isempty(mess)
    display_message(mess)
elseif ~ok
    error_message(mess)
end


% Set object properties
% ---------------------
% Set data properties
obj.data_ = args;
obj.ndim_ = ndim;
[obj.ndata_,obj.ndatatot_,obj.item_,obj.ix_] = data_indicies(ndim);

obj.w_ = w;
obj.msk_ = msk_out;

% Clear function and constraints properties, retaining current global/local scopes
S_fun = fun_init (obj.ndatatot_, obj.foreground_is_local_, obj.background_is_local_);
S_con = constraints_init (S_fun.np_, S_fun.nbp_);

obj = obj.set_fun_props_ (S_fun);
obj = obj.set_constraints_props_ (S_con);
