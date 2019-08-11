function [x_av, x_var] = moments_ (obj)
% Calculate mean and variance of a probability distribution
%
%   >> ok = moments_ (obj)
%
% Input:
% ------
%   obj     pdf_table object
%
% Output:
% -------
%   x_av    First moment of the distribution obtained by linking the points
%           that define the probability distribution.
%
%   x_var   Variance of the distribution
%
% Uses correct integration of the trapezoidal function to return the mean.


if ~isscalar(obj), error('Method only takes a scalar object'), end
if ~obj.filled
    error('The probability distribution function is not initialised')
end

dx = diff(obj.x_);
df = diff(obj.f_);
xbar = (obj.x_(2:end)+obj.x_(1:end-1))/2;
fbar = (obj.f_(2:end)+obj.f_(1:end-1))/2;

area = fbar.*dx;
ok = (area>0);

dx = dx(ok);
df = df(ok);
xbar = xbar(ok);
area = area(ok);

% Area (should be unity!)
area_tot = sum(area);

% Mean
dxsqr = dx.*dx;
area_lambda = area.*xbar + (df.*dxsqr)/12;
x_av = sum(area_lambda)/area_tot;

% Variance
if nargout==2
    del_xbar = xbar - x_av;
    tmp = area.*dxsqr/12 + del_xbar.*(area.*del_xbar + df.*dxsqr/6);
    x_var = sum(tmp)/area_tot;
end
