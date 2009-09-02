function w = cut_horace(varargin)
% Take a cut from a file containing sqw or d0d/d1d/...d4d object, as appropriate to file contents
%
% Syntax:
%   >> w=cut_horace (file, arg1, arg2, ...)
%   >> w=cut_horace (arg1, arg2,...)          % prompts for file
%
% For full details of arguments for cut method, type:
%
%   >> help sqw/cut             % cut for sqw objects
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

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
    function_horace(file_internal,@cut,varargin{1+noffset:end});
else
    w = function_horace(file_internal,@cut,varargin{1+noffset:end});
end
