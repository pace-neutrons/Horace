function obj = set_fun_props_ (obj, S)
% Set the functions properties from a structure
%
%   >> obj = set_fun_props_ (obj, S)
%
% Input:
% ------
%   obj     mfclass object
%   S       Functions structure on output: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
% Output:
% -------
%   obj     mfclass object


% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


obj.foreground_is_local_ = S.foreground_is_local_;
obj.fun_ = S.fun_;
obj.pin_ = S.pin_;
obj.np_ = S.np_;
obj.free_ = S.free_;

obj.background_is_local_ = S.background_is_local_;
obj.bfun_ = S.bfun_;
obj.bpin_ = S.bpin_;
obj.nbp_ = S.nbp_;
obj.bfree_ = S.bfree_;

