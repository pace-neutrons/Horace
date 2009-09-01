function wout = IXTdataset_2d (w)
% Convert d2d object into IXTdataset_2d
%
%   >> wout = IXTdataset_2d (w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

wout=IXTdataset_2d(sqw(w));
