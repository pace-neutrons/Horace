function w = cut_dnd(varargin)
% Take a cut from a file containing sqw or d0d/d1d/...d4d object, as appropriate to file contents.
% If data is sqw-type i.e. has pixel information, this is ignored and is treated as equivalent
% d0d, d1d,...d4d object.
%
% Syntax:
%   >> w=cut_dnd (file, arg1, arg2, ...)
%   >> w=cut_dnd (arg1, arg2,...)          % prompts for file
%
% For full details of arguments for cut method, type:
%
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

% Get filename
if nargin>=1 && ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1    % is a single row of characters
    noffset=1;
    if (exist(varargin{1},'file')==2)
        file_internal = varargin{1};
    else
        file_internal = getfile(varargin{1});
    end
else
    noffset=0;
    file_internal = getfile('*.sqw;*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
end

% Make object
if nargout==0
    function_dnd(file_internal,@cut,varargin{1+noffset:end});
else
    w = function_dnd(file_internal,@cut,varargin{1+noffset:end});
end
