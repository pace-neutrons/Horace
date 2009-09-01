function wout = IXTdataset_1d (w)
% Convert d1d object into IXTdataset_1d
%
%   >> wout = IXTdataset_1d (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

wout=IXTdataset_1d(sqw(w));
