function writegrid (w, binfil)
% Writes 1D dataset to a binary file.
%
% Syntax:
%   >> writegrid (data, binfil)
%
% Input:
% ------
%   w       1D Dataset
%   binfil  Name of file to whicht he data will be written.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

if nargin==1
    dnd_writegrid(get(w))
else
    dnd_writegrid(get(w),binfil)
end