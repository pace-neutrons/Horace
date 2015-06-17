function [t_red,t_av] = area_to_t_ikcarp2 (area, tauf, taus, R)
% Inverse function to cumulative integral of a normalised Ikeda-Carpenter function
%
%   >> x = area_to_t_ikcarp2 (area, tauf, taus, r)
%
% This is a 'fast' version of area_to_t_ikcarp for computing the inverse on a uniform
% area, but with limited accuracy:
%   - tauf/taus>0.01 then dt/t <1e-4   for all R
%   - tauf/taus>0.02 then dt/t <2e-5   for all R
%
% This algorithm is about 10 times faster for an area array with 50 points, and
% 100 times faster for 500 areas.
%
% The swap-over time is at about 5 area points. The original area_to_ikcarp2 is
% called for 5 points or fewer.
%
% Input:
% ------
%   area    Array of areas (0 <=area <=1)
%   tauf    Fast decay time (us)
%   taus    Slow decay time (us)
%   R       Weight of storage term
%
% Output:
% -------
%   t_red   Array of reduced times t_red = t/(t+t_av) such that area is the integral from 0 to t
%           of the Ikeda-Carpenter function. t_av is the first moment of the Ikeda-Carpenter
%           function
%   t_av    First moment of the Ikeda-Carpenter function: t_av = 3*tauf + R*taus

% T.G.Perring 2014-02-20

% For small number of points, use slow but accurate algorithm - it is faster
% if numel(area)<=5
%     [t_red,t_av] = area_to_t_ikcarp (area, tauf, taus, R);
%     return
% end

% Speedy algorithm for more than 5 points
nmax=500;

% Times suitable for interpolation on fast term:
xmax=area_to_t_ikcarp(max(area),tauf,0,0);
x=(xmax/nmax)*(0:nmax);
tfast=(x./(1-x))*(3*tauf);

% Times suitable for interpolation on slow term:
xmax=area_to_t_ikcarp(max(area),tauf,taus,1);
x=(xmax/nmax)*(0:nmax);
tslow=(x./(1-x))*(3*tauf+taus);

% The combined range of times will definitely cover the area of the true function to max(area)
t=[tfast,tslow];
A=area_ikcarp(t,tauf,taus,R);   % area array at times t
[A,ix]=unique(A);   % ensure strictly monotonic increasing areas
t=t(ix);

t_av=3*tauf+R*taus;
ti=interp1(A,t,area,'linear','extrap')/t_av;      % interpolated times, normalised by t_av
t_red=ti./(1+ti);

