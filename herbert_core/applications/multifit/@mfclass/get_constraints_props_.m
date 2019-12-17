function S = get_constraints_props_ (obj)
% Get the constraints properties in a structure
%
%   >> S = get_constraints_props_ (obj)
%
% Input:
% ------
%   obj     mfclass object
%
% Output:
% -------
%   S       Constraints structure on output: fields are
%               bound_
%               bound_to_
%               ratio_
%               bound_to_res_
%               ratio_res_


% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


S = struct(...
    'bound_', obj.bound_,...
    'bound_to_', obj.bound_to_,...
    'ratio_', obj.ratio_,...
    'bound_to_res_', obj.bound_to_,...
    'ratio_res_', obj.ratio_);

