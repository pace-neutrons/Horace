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
% $Revision$ ($Date$)


S = struct(...
    'bound_', obj.bound_,...
    'bound_to_', obj.bound_to_,...
    'ratio_', obj.ratio_,...
    'bound_to_res_', obj.bound_to_,...
    'ratio_res_', obj.ratio_);
