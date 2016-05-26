function obj = set_constraints_props_ (obj, S)
% Get the constraints properties in a structure
%
%   >> obj = set_constraints_props_ (obj, S)
%
% Input:
% ------
%   obj     mfclass object
%
% Output:
% -------
%   obj     mfclass object
%   S       Constraints structure on output: fields are
%               free_
%               bound_
%               bound_to_
%               ratio_
%               bound_from_
%
% Output:
% -------
%   obj     mfclass object


obj.free_ = S.free_;
obj.bound_ = S.bound_;
obj.bound_to_ = S.bound_to_;
obj.ratio_ = S.ratio_;
obj.bound_from_ = S.bound_from_;
