function wout = permute (win,varargin)
% Permute the order of the display axes. Syntax the same as the matlab array permute function
%
% Syntax:
%   >> wout = permute (win, order)
%
%   >> wout = permute (win)         % increase axis indices by one (& last index=1)
%
% Input:
% ------
%   win             Input object.
%
%   order           Order of axes: a row vector with length equal to the dimension of
%                  the dataset. The display axes are rearranged into the order specified
%                  by the the elements this argument.
%                   If the argument is omitted, then the axes are cycled by one i.e.
%                  i.e. is equivalent to order = [2,3..ndim,1]
%
%
% Output:
% -------
%   wout            Output object.
%
%
% Example: if input object is 3D
%   >> wout = permute (win, [3,1,2]) % the current 3rd, 1st and 2nd dispaly axes 
%                                    % become the 1st, 2nd and 3rd of the output object
%
%   >> wout = permute (win)          % equivalent to permute(win,[2,3,1])
%


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(permute(sqw(win),varargin{:}));
