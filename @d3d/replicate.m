function wout = replicate (win, wref)
% Make a higher dimensional dataset from a three dimensional dataset by
% replicating the data along the extra dimensions of a reference dataset.
%
% Syntax:
%   >> wout = replicate (win, wref)
%
% Input:
% ------
%   win     Three dimensional dataset.
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
%   wout    Output dataset structure.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if isa(win,classname)
    wout=dnd(replicate(sqw(win),wref));
else
    error('Check input argument types')
end
