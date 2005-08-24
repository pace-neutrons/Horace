function dout = dnd_permute (din, varargin)
% Permute the order of the plot axes. Syntax the same as the matlab array permute function
%
% Syntax:
%   >> dout = dnd_permute (din, order)
%
%   >> dout = dnd_permute (din)         % increase axis indices by one (& last index=1)
%
% Input:
% ------
%   din             Input dataset.
%
%   order           Order of axes: a row vector with length equal to the dimension of
%                  the dataset. The plot axes are rearranged into the order specified
%                  by the the elements this argument.
%                   If the argument is omitted, then the axes are cycled by one i.e.
%                  i.e. is equivalent to order = [2,3..ndim,1]
%
%
% Output:
% -------
%   dout            Output dataset. Its elements are the same as those of din,
%                  appropriately updated.
%
%
% Example: if input dataset is 3D
%   >> dout = permute (din, [3,1,2]) % the current 3rd, 1st and 2nd plot axes 
%                                    % become the 1st, 2nd and 3rd of the output dataset
%
%   >> dout = permute (din)          % equivalent to permute(din,[2,3,1])
%                                                           

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring


% Check number, size and type of input arguments
ndim = length(din.pax);

if nargin==1    % permute by unity
    if ndim>1
        order = [linspace(2,ndim,ndim-1),1];
    else
        dout = din;     % nothing to permute
        return
    end
end

if nargin==2
    if iscell(varargin{1}) % interpret as having been passed a varargin (as cell array is not a valid type to be passed to dnd_permute)
        args = varargin{1};
    else
        args = varargin;
    end
    if length(args)~=1 || ~isa_size(args{1},[1,ndim],'double')
        error ('ERROR: Permutation argument must be a row vector with length equal to dimension of input dataset')
    end
    order = args{1};
end

% permute data array
if sort(order)~=linspace(1,1,ndim) % invalid permutation array
    error (['ERROR: New axis order must be a permutation of the integers 1-',num2str(ndim)])
elseif order==linspace(1,1,ndim)   % order is unchanged
    dout = din;
    return
end

dout = din;
dout.pax = din.pax(order);
for i=1:ndim
    pin  = ['p', num2str(order(i))];
    pout = ['p', num2str(i)];
    dout.(pout) = din.(pin);    % use dynamic field names facility of Matlab to permute the axes arrays
end
dout.s = permute(din.s,order);
dout.e = permute(din.e,order);
dout.n = permute(din.n,order);
