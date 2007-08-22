function w = combine_libisis (d0d, s)
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
% $Revision: 103 $ ($Date: 2007-01-29 09:32:02 +0000 (Mon, 29 Jan 2007) $)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

w = d0d;        % output d1d will be mostly the input d0d
for i=1:numel(s)
    w(i).s  = s(i).val;
    w(i).e  = (s(i).err).^2;
end