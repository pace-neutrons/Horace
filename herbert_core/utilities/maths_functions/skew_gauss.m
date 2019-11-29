function y = skew_gauss (x, xmean, sig, alf)
% Normalised skew Gaussian function
%
%   >> y = skew_gauss (x, xmean, sig, alf)
%
% Input:
% ------
%   x       Array of x values at which to evaluate the function
%   xmean   Position of mean of the slew normal
%   sig     Standard deviation
%   alf     Assymetry paraeter in the range [-Inf,Inf]. If alf=0 then
%          the function reduces to a Gaussian; if alf>0 skewed to larger
%          tail for positive x; if alf<0 skewed to negative x.
%
% Output:
% -------
%   y       Value of function. The distributrion is defined as
%          the product of a Gaussian and the complementary error function
%          See https://en.wikipedia.org/wiki/Skew_normal_distribution for
%          details.


% T.G.Perring 2015-08-05

mu0=sqrt(2/pi)*(alf/sqrt(1+alf^2));
sig0=sqrt(1-mu0^2);

xtmp=(sig0/sig)*(x-xmean) + mu0;
y=((sig0/sig)/sqrt(2*pi))*(exp(-0.5*xtmp.^2).*erfc(-xtmp*(alf/sqrt(2))));
