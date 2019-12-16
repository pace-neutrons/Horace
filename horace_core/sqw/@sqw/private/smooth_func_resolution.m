function c = smooth_func_resolution(width)
% Fills a two dimensional matrix with a correlated Gaussian function
% Output matrix normalised so sum of elements = 1
%
% Syntax:
%   >> c = smooth_func_resolution(width)
%
%   width   Vector containing:
%           The convolution matrix extends to 2% of the peak intensity 
%
%   c       Convolution array

% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

f = 0.02;   % convolution matrix will extend to the 2% contour of the multi-dimensional Gaussian

% Get the Gaussian form
q_fwhh=width(1); e_fwhh=width(2); dedq=width(3);
m=get_gauss_form(q_fwhh, e_fwhh, dedq);
sig_q=sqrt(m(2,2)/(m(1,1)*m(2,2)-m(1,2)*m(2,1)));
sig_e=sqrt(m(1,1)/(m(1,1)*m(2,2)-m(1,2)*m(2,1)));

fac = sqrt(-2*log(f));
qmax=fac*sig_q;
emax=fac*sig_e;

nx=floor(qmax);
ny=floor(emax);

x=-nx:nx;
y=-ny:ny;
[xx,yy]=ndgrid(x,y);
c=gauss_form(xx,yy,m);
c=c/max(c(:));      % peak is set to unity to get minimum contour
c(c<f)=0;         % elements less than f set to zero - will not contribute to convolution
c = c/sum(c(:));  % normalise so sum of elements is unity

%----------------------------------------------------------------------------------------------
function m=get_gauss_form(q_fwhh, e_fwhh, dedq)
% Get Gaussian form from FWHH excluding energy term, overall energy FWHH, and
% slope of Q-E ellispoid.
% This is used in an approximation tot he resolution function
%
%   f(Q,e)=A * exp(-(m(1,1)*Q^2 +2*m(1,2)*Q*E + m(2,2)*E^2)/2)
% 
% m is returned as a 2x2 matrix
%
% T.G.Perring 19 August 2008
%

q_sig=q_fwhh/sqrt(log(256));
e_sig=e_fwhh/sqrt(log(256));
g=dedq;

m=zeros(2,2);

m(1,1)=1/q_sig^2;
m(1,2)=-1/(g*q_sig^2);
m(2,1)=m(1,2);
m(2,2)=1/e_sig^2 + 1/(g*q_sig)^2;

%----------------------------------------------------------------------------------------------
function f=gauss_form(x,y,m)
% Calculate Gaussian form at values x,y
%
%   f(x,y) = A * exp(-(m(1,1)*x^2 +2*m(1,2)*x*y + m(2,2)*y^2)/2)
% 
% A is chosen so that the function is normalised; m is a 2x2 matrix
%
% T.G.Perring 19 August 2008
%

A=sqrt(m(1,1)*m(2,2)-m(1,2)*m(2,1))/(2*pi);
f = A * exp(-(m(1,1)*x.^2 +2*m(1,2)*(x.*y) + m(2,2)*y.^2)/2);


