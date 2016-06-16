function obj = set_data(obj,varargin)
% Set data, clearing all data and functions
%
%   >> obj = obj.set_data ()             % clears all data
%   >> obj = obj.set_data (x,y,z)
%   >> obj = obj.set_data (w1,w2,...)
%
% The scope of the foreground and background functions as being global or
% local is not altered, even though all data and functions are cleared.
% That is, for example, if the foreground was declared as local, it
% will remain so, meaning that one function per data set will be expected
% when the functions are set.


% Trivial case of no input arguments; just return without doing anything
if numel(varargin)==0, return, end

% Find optional arguments
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[args,keyval,~,~,ok,mess] = parse_arguments (varargin, keyval_def);
if ~ok, error(mess), end

% Check input data
[ok, mess, ndim, w] = is_valid_data (args{:});
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
