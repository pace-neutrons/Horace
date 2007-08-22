function w = combine_libisis (d2d, s)
% Use fields from a 2D dataset and a Libisis IXTdataset_2d object to construct an
% output 2D dataset. Used as a utility in binary operations and other
% functions that manipulate 2D datasets.
%
% Use in conjuction with convert_to_libisis.
%
% Syntax:
%   >> w = combine_libisis(d2d, s)

% Original author: T.G.Perring
%
% $Revision: 103 $ ($Date: 2007-01-29 09:32:02 +0000 (Mon, 29 Jan 2007) $)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

w = d2d;        % output d1d will be mostly the input d1d
for i=1:numel(s)
    w(i).p1 = s(i).x';                  % some functions alter the x axis e.g. rebin
    w(i).p2 = s(i).y';
    w(i).s  = s(i).signal;
    w(i).e  = (s(i).error).^2;
end