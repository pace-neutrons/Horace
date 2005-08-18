function w = combine_d1d_spectrum (d1d, s)
% Use fields from a 1D dataset and an mgenie spectrum to construct an
% output 1D dataset. Used as a utility in binary operations and other
% functions that manipulate 1D datasets.
%
% Syntax:
%   >> w = combine_d1d_spectrum (d1d, s)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

w = d1d;        % output d1d will be mostly the input d1d
temp = get(s);  % get fields of spectrum

w.p1 = temp.x';                 % some functions alter the x axis e.g. rebin
w.s  = temp.y;
w.e  = (temp.e).^2;
w.n  = ones(length(w.s),1);
w.n(find(isnan(temp.y))) = 0;   % Ensure that n = 0 where y values are nan