function wout = permute (win, varargin)
% Permutation of the axes of a 1D dataset is a dummy operation with output
% equal to input because there is only one axis to permute. This routine
% provided only for completeness with 2D, 3D,4D dataset functionality.
%
% Syntax:
%   >> wout = permute (win)         % swap the axes (i.e. equivalent
%                                     to wout = permute (win, [2,1])
%   >> wout = permute (win, order)  % general permutation. Only valid
%                                     input is order = 1
%
%
% Input:
% ------
%   win             Data from which a reduced dimensional manifold is to be taken.
%
%   order           Order of axes: a row vector with length equal to the dimension of
%                  the dataset. The plot axes are rearranged into the order specified
%                  by the the elements this argument.
%                   If the argument is omitted, then the axes are cycled by one i.e.
%                  i.e. is equivalent to order = [2,3..ndim,1]
%
% Output:
% -------
%   wout            Output dataset. Its elements are the same as those of din,
%                  appropriately updated.
%
%
% Example: 
%   >> wout = permute (win, 1) 
%                                                           
%   >> wout = permute (win)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    wout = dnd_create(dnd_permute(get(win)));
else
    wout = dnd_create(dnd_permute(get(win),varargin));
end
