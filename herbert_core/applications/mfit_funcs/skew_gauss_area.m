function y = skew_gauss_area (x, p)
% Normalised skew Gaussian function
%
%   >> y = skew_gauss_area (x, p)
%
% Input:
% ------
%   x       Array of x values at which to evaluate the function
%   p       Vector of parameters [area, xmean, sig, alf] where:
%               area    Integrated area
%               xmean   Position of mean of the slew normal
%               sig     Standard deviation
%               alf     Asymmetry parameter in the range [-Inf,Inf]. If alf=0 then
%                      the function reduces to a Gaussian; if alf>0 skewed to larger
%                      tail for positive x; if alf<0 skewed to negative x.
%
% Output:
% -------
%   y       Value of function. The distributrion is defined as
%          the product of a Gaussian and the complementary error function
%          See https://en.wikipedia.org/wiki/Skew_normal_distribution for
%          details.


% T.G.Perring 2015-08-05

area=p(1); xmean=p(2); sig=p(3); alf = p(4);

y = area * skew_gauss (x, xmean, sig, alf);
