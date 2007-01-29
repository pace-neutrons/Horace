function w = combine_d1d_spectrum (d1d, s)
% Use fields from a 1D dataset and an mgenie spectrum to construct an
% output 1D dataset. Used as a utility in binary operations and other
% functions that manipulate 1D datasets.
%
% Use in conjuction with d1d_to_spectrum.
%
% Syntax:
%   >> w = combine_d1d_spectrum (d1d, s)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

w = d1d;        % output d1d will be mostly the input d1d
for i=1:prod(size(s))
    temp = get(s(i));  % get fields of spectrum

    w(i).p1 = temp.x;                  % some functions alter the x axis e.g. rebin
    w(i).s  = temp.y;
    w(i).e  = (temp.e).^2;
    w(i).n  = ones(length(w(i).s),1);

    % If s was created from d1d_to_spectrum (as will normally be the case),
    % then reset the counts to zero for those pixels which were indicated as
    % containing zero by giving y value = NaN:
    w(i).n(find(isnan(temp.y))) = 0;   % Ensure that n=0 where y values are nan

end