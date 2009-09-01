function w = read_dnd(varargin)
% Read d0d, d1d, d2d, d3d or d4d object from a file
% 
%   >> w=read_dnd           % prompts for file
%   >> w=read_dnd(file)

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

% Get filename
if nargin==1 && ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1    % is a single row of characters
    noffset=1;
    if (exist(varargin{1},'file')==2)
        file_internal = varargin{1};
    else
        file_internal = getfile(varargin{1});
    end
elseif nargin==0
    noffset=0;
    file_internal = getfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
else
    error ('Input must be a file name')
end

% Make object
w=function_dnd(file_internal,@read,varargin{1+noffset:end});
