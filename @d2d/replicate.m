function wout = replicate (win, wref)
% Make a higher dimensional dataset from a two dimensional dataset by
% replicating the data along the extra dimensions.
%
% Syntax:
%   >> wout = replicate (win, wref)
%
% Input:
% ------
%   win     Two dimensional dataset.
%
%   wref    Reference dataset structure to use as template for expanding the 
%           input straucture.
%           - The plot axes of win must also be plot axes of wref, and the number
%           of points along these common axes must be the same, although the
%           numerical values of the coordinates need not be the same.
%           - The data is expanded along the plot axes of wref that are 
%           integration axes of win. 
%           - The annotations etc. are taken from the reference dataset.
%
% Output:
% -------
%   dout    Output dataset structure.
%

% Original author: T.G.Perring
%
% $Revision: 73 $ ($Date: 2005-08-24 17:48:25 +0100 (Wed, 24 Aug 2005) $)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% Check that plot axes are common, and that the dref is greater or equal dimensionality
wout = dnd_create(dnd_replicate(get(win),get(wref)));