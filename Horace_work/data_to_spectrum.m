function w = data_to_spectrum (din)
% Convert a 1D Horace dataset to an mgenie spectrum

% Author:
%   T.G.Perring     28/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

x = din.p1;
y = din.s./double(din.n);
e = sqrt(din.e)./double(din.n);
[title, xlab] = cut_titles (din);
ylab = 'Intensity (arb. units)';
xunit = '';
distribution = 0;

w = spectrum (x,y,e,title,xlab,ylab,xunit,distribution);
