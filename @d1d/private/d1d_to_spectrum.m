function w = d1d_to_spectrum (d1d)
% Use fields from a 1D dataset to construct an mgenie spectrum for mathematical
% manipulation, plotting etc. Used as a utility in binary operations on 1D datasets.

% Author:
%   T.G.Perring     03/07/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

x = d1d.p1;
ndouble = d1d.n;
ndouble(find(ndouble==0)) = nan;    % replace infinities with NaN
y = d1d.s./double(ndouble);
e = sqrt(d1d.e)./double(ndouble);
[title, xlab] = cut_titles (get(d1d));
ylab = 'Intensity (arb. units)';
xunit = '';
distribution = 0;

w = spectrum (x,y,e,title,xlab,ylab,xunit,distribution);
