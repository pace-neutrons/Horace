function wout = permute (win, order)
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

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% This method applies equally to sqw-type and dnd-type objects

% Check number, size and type of input arguments
ndim = length(win.data.p);

if ~exist('order','var')
    if ndim<=1
        wout = win;     % nothing to permute
        return
    else
        order = [linspace(2,ndim,ndim-1),1];
    end

else
    if ~isa_size(order,[1,ndim],'double')
        error (['Permutation argument must be a row vector with length equal to dimension of input dataset: ndim = ',num2str(ndim)])
    end
    if ~isequal(sort(order),(1:ndim))   % invalid permutation array
        error (['ERROR: New axis order must be a permutation of the integers 1-',num2str(ndim)])
    end
end

% Permute data array
if isequal(order,(1:ndim))      % order is unchanged
    wout = win;
else
    wout = win;
    wout.data.dax = win.data.dax(order);
end
