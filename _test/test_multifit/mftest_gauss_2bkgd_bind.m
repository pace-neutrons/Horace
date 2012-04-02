function y = mftest_gauss_2bkgd_bind(x, p)
% Gaussian on two backgrounds for compariosn with global Gaussian fitted to two datasets
% 
%   >> y = mftest_gauss_2bkgd_bind(x,p)
%
% Input:
% =======
%   x   vector of x-axis values at which to evaluate function
%   p   vector or parameters needed by the function:
%           p = [h1, c1, sig1, b1, g1, b2, g2]
%
% Output:
% ========
%   y       Vector of calculated y-axis values

% T.G.Perring

% Simply calculate function at input values
ht=p(1);
cen=p(2);
sig=p(3);
b1=p(4);
g1=p(5);
b2=p(6);
g2=p(7);

% Do some binding
cen=1.25*b1;
sig=0.25*b2;
g2=-g1;

% Recall we have two test spectra:
x=reshape(x,[2,numel(x)/2]);
y=ht*exp(-0.5*((x-cen)/sig).^2);
y(1,:)=y(1,:)+b1+x(1,:)*g1;
y(2,:)=y(2,:)+b2+x(2,:)*g2;
y=y(:);
