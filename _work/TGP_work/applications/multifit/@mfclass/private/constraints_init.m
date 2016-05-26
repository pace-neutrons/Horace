function obj = constraints_init (np_, nbp_)
% Initialise constraints properties from the current function properties
%
%   >> obj = constraints_init (np_, nbp_)
%
% Input:
% ------
%   np_     Array of number of foreground parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%   nbp_    Array of number of background parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%
% Output:
% -------
%   obj     Constraints structure on output: fields are 
%               free_
%               bound_
%               bound_to_
%               ratio_
%               bound_from_


n = sum(np_) + sum(nbp_);

obj.free_ = true(n,1);
obj.bound_ = false(n,1);
obj.bound_to_ = zeros(n,1);
obj.ratio_ = NaN(n,1);
obj.bound_from_ = sparse([],[],[],n,n,n);
