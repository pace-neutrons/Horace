function wout = IXTdataset_1d (w)
% Convert d1d object into IXTdataset_1d
%
%   >> wout = IXTdataset_1d (w)

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

wout=IXTdataset_1d(sqw(w));
