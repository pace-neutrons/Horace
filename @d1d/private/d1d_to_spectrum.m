function w = d1d_to_spectrum (d1d)
% Use fields from a 1D dataset to construct an mgenie spectrum for mathematical
% manipulation, plotting etc.
%
% Use in conjuction with combine_d1d_spectrum to reassemble a 1D dataset after
% using the mgenie spectrum methods.
%
% Syntax:
%   >> w = d1d_to_spectrum (d1d)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

x = d1d.p1;
n = d1d.n;
n(find(n==0)) = nan;    % replace infinities with NaN
y = d1d.s./n;
e = sqrt(d1d.e)./n;
[title, xlab] = dnd_cut_titles (get(d1d));
ylab = 'Intensity (arb. units)';
xunit = '';
distribution = 0;

w = spectrum (x,y,e,title,xlab,ylab,xunit,distribution);
