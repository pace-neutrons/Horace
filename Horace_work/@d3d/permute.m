function wout = permute (win, varargin)
% Permute the order of the plot axes. Syntax the same as the matlab array permute function
%
% Syntax:
%   >> wout = permute (win)         % cycle the axes by unity (i.e. equivalent
%                                     to wout = permute (win, [2,3,1])
%   >> wout = permute (win, order)  % general permutation
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
%   >> wout = permute (win, [3,1,2]) % the current 3rd, 1st and 2nd plot axes 
%                                    % become the 1st, 2nd and 3rd of the output dataset
% 
%   >> wout = permute (win)          % equivalent to wout = permute (win, [2,3,1])
%                                                           

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
