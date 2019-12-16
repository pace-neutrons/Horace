function obj = set_data(obj,varargin)
% Set data, clearing all data, functions and constraints
%
% If data in the form of objects is expected:
%   >> obj = obj.set_data (w1,w2,...)   % Set objects or arrays of objects
%
% If x,y,e data is valid (i.e. datasets are not required to be objects)
%   >> obj = obj.set_data (x,y,z)       % Set x,y,e, data
%   >> obj = obj.set_data (w1,w2,...)   % Set cell arrays or structures of
%                                       % x,y,e, data
% Remove all data:
%   >> obj = obj.set_data ()
%   >> obj = obj.set_data ([])
%
% More details on data formats are given below below
%
%
% In addition, portions of the data sets can be masked using one or more of
% the optional keyword-value pairs (keyword-value pairs can appear in any order):
%
%   >> obj = obj.set_data (...'keep', xkeep, 'remove', xremove, 'mask', mask)
%
% For full details of masking syntax, see <a href="matlab:help('mfclass/set_mask');">set_mask</a>
%
%
% Format of data
% --------------
% If data set(s) are objects: each of w1, w2, ... has the form
%       w       Data object or array of data objects all of the same class
%
% If data set(s) are x-y-e data:
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
% If multiple x-y-e data sets: each of w1, w2, ... has the form
%   - Cell array of arrays x, y, e above (defines a single dataset):
%       w = {x,y,e}
%
%   - Cell array of cell arrays that defines multiple datasets:
%       w = {{x1,y1,e1}, {x2,y2,e2}, {x3,y3,e3},...}
%
%   - Structure with fields w.x, w.y, w.e  where x, y, e have one of the
%     forms described above (this defines a single dataset)
%
%   - Structure array with fields w(i).x, w(i).y, w(i).e (this defines
%     several datasets)
%
% See also append_data remove_data replace_data

 
% Original author: T.G.Perring 
% 
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


% Find arguments and optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,present,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end
if isempty(args) && any(cellfun(@logical,struct2cell(present)))
    error('Syntax error: no input data was given but optional arguments were provided')
end

% Check input data
class_name = obj.dataset_class_;
[ok, mess, w] = is_valid_data (class_name, args{:});
if ~ok, error(mess), end

% Check optional arguments
[ok,mess,xkeep,xremove,msk] = mask_syntax_valid (numel(w), keyval.keep, keyval.remove, keyval.mask);
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
% The following should work even if no data sets are set

% Set data properties
obj.data_ = args;
obj.w_ = w;
obj.msk_ = msk_out;

% Clear function and constraints properties, retaining current global/local scopes
Sfun = functions_init (numel(w), obj.foreground_is_local_, obj.background_is_local_);
Scon = constraints_init (Sfun.np_, Sfun.nbp_);

obj = obj.set_fun_props_ (Sfun);
obj = obj.set_constraints_props_ (Scon);

