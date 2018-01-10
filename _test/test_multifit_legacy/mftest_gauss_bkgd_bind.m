function y = mftest_gauss_bkgd_bind(x, p)
% Gaussian
% 
%   >> y = mftest_gauss_bkgd_bind(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function, and :
%           p = [h1, c1, sig1, const, grad, rat1, rat2, .. rat5, bp1, bp2, ...bp5]
%          where
%           rat1    ratio of parameter 1 to binding parameter
%           bp1     index of binding parameter (1,2,3,4,5)
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% T.G.Perring

% Resolve binding
rat=p(6:10);
bp=p(11:15);
ind=(bp~=0);
p(ind)=rat(ind).*p(bp(ind));

% Simply calculate function at input values
ht=p(1);
cen=p(2);
sig=p(3);
const=p(4);
grad=p(5);

y=ht*exp(-0.5*((x-cen)/sig).^2) + (const+x*grad);
