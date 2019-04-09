function obj = remove_data (obj, ind)
% Remove data sets, clearing corresponding functions and constraints
%
% Remove all data:
%   >> obj = obj.remove_data
%   >> obj = obj.remove_data ('all')
%
% Remove one or more particular datasets (ind is a scalar or row vector):
%   >> obj = obj.remove_data (ind)
%
% See also append_data replace_data set_data 
 

% Note for developers:
%   >> obj = obj.replace_data ([])      % Inert operation: does nothing


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)


% Find arguments
if nargin==1
    ind = 'all';
end
[ok,mess,idata] = indicies_parse (ind, obj.ndatatot_, 'Dataset');
if ~ok, error(mess), end
 

% Set object properties
% ---------------------
[ok, mess, data_out] = dataset_remove (obj.data_, idata);
if ~ok, error(mess), end

keep = true(1,obj.ndatatot_);
keep(idata) = false;

obj.data_ = data_out;
obj.w_ = obj.w_(keep);
obj.msk_ = obj.msk_(keep);


% Remove function and constraints
Sfun = obj.get_fun_props_;
Scon = obj.get_constraints_props_;

if obj.foreground_is_local_
    Sfun = functions_remove (Sfun, true, idata);
    Scon = constraints_remove (Scon, obj.np_, obj.nbp_, idata, []);
elseif ~any(keep)   % clear if no data at all, otherwise retain the global function
    Sfun = functions_remove (Sfun, true, 'all');
    Scon = constraints_remove (Scon, obj.np_, obj.nbp_, 'all', []);
end

if obj.background_is_local_
    Sfun = functions_remove (Sfun, false, idata);
    Scon = constraints_remove (Scon, obj.np_, obj.nbp_, [], idata);
elseif ~any(keep)
    Sfun = functions_remove (Sfun, false, 'all');
    Scon = constraints_remove (Scon, obj.np_, obj.nbp_, [], 'all');
end

obj = obj.set_fun_props_(Sfun);
obj = obj.set_constraints_props_ (Scon);
