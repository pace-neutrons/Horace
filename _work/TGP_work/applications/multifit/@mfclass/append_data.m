function obj = append_data(obj,varargin)
% Append datasets to the list of current datasets
%
%   >> obj = obj.append_data ()             % Inert operaton: does nothing
%   >> obj = obj.append_data (w1,w2,...)    % Set objects or arrays of objects
%   >> obj = obj.append_data (x,y,z)        % If valid: append x,y,e, data
%
% For more details about data formats see <a href="matlab:doc('mfclass/set_data');">set_data</a>
%
% See also set_data remove_data replace_data
 
 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$)


% Trivial case of no input arguments; just return without doing anything
if numel(varargin)==0, return, end

% Find optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,~,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end

% Check input
class_name = obj.wrapfun_.dataset_class;
[ok, mess, ndim, w] = is_valid_data (class_name, args{:});
if ~ok, error(mess), end

% Append dataset(s) to end of existing collection of datasets
[ndata,ndatatot,item,ix] = data_indicies(ndim);

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
ndatatot_init = obj.ndatatot_;
if isempty(obj.data_)
    obj.data_ = args;
    obj.ndim_ = ndim;
    obj.ndata_ = ndata;
    obj.ndatatot_ = ndatatot;
    obj.item_ = item;
    obj.ix_ = ix;
    obj.w_ = w;
    obj.msk_ = msk_out;
else
    if numel(obj.data_)==3 && obj.ndatatot_==1  % data is {x,y,e}
        obj.data_ = {obj.data_};
    end
    if numel(args)==3 && numel(ndim)==1     % new data is {x,y,e}
        args = {args};
    end
    obj.data_ = [obj.data_, args];
    obj.ndim_ = [obj.ndim_, ndim];
    obj.ndata_ = [obj.ndata_, ndata];
    obj.ndatatot_ = obj.ndatatot_ + ndatatot;
    obj.item_ = [obj.item_; ndatatot_init+item];
    obj.ix_ = [obj.ix_; ix];
    obj.w_ = [obj.w_, w];
    obj.msk_ = [obj.msk_, msk_out];
end

% Append function properties
% (Only need to append properties if the number of datasets has changed
% Note that constraints properties do not need to be changed, as the default
% is to have no parameters)
if obj.ndatatot_ ~= ndatatot_init && ...
        (obj.foreground_is_local_ || obj.background_is_local_)
    S_fun = obj.get_fun_props_;
    dn = obj.ndatatot_ - ndatatot_init;
    if obj.foreground_is_local_
        S_fun = fun_append (S_fun, true, dn);
    end
    if obj.background_is_local_
        S_fun = fun_append (S_fun, false, dn);
    end
    obj = obj.set_fun_props_(S_fun);
end
