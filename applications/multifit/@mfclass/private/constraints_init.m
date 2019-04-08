function Scon = constraints_init (np_, nbp_)
% Initialise constraints properties structure from the current function properties
%
%   >> Scon = constraints_init (np_, nbp_)
%
% Input:
% ------
%   np_     Array of number of foreground parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%
%   nbp_    Array of number of background parameters in each function in the
%          underlying definition of the constraints structure (row vector)
%
% Output:
% -------
%   Scon    Constraints structure on output: fields are 
%               bound_
%               bound_to_
%               bound_to_res_
%               ratio_
%               ratio_res_


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)


n = sum(np_) + sum(nbp_);

Scon.bound_ = false(n,1);
Scon.bound_to_ = zeros(n,1);
Scon.ratio_ = zeros(n,1);
Scon.bound_to_res_ = zeros(n,1);
Scon.ratio_res_ = zeros(n,1);
