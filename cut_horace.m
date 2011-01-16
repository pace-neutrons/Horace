function w = cut_horace(varargin)
% Take a cut from a file containing sqw or d0d/d1d/...d4d object, as appropriate to file contents
%
% Syntax:
%   >> w=cut_horace (file, arg1, arg2, ...)
%   >> w=cut_horace (file, arg1, arg2, ...) % data in named file, or cell array of filenames
%                                           % Output is an array if given cell array of files
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

% Catch case of sqw object or dnd object
if nargin==1 && (isa(varargin{1},'sqw')||isa(varargin{1},'d0d')||isa(varargin{1},'d1d')||...
        isa(varargin{1},'d2d')||isa(varargin{1},'d3d')||isa(varargin{1},'d4d'))
    if nargout==0
        cut(varargin{:});
    else
        w=cut(varargin{:});
    end
    return
end

% Check file name(s), prompting if necessary
if nargin==0
    error('Must give file name or cell array of filenames of sqw or d0d, d1d,...d4d object(s)')
else
    [file_internal,mess]=getfile_horace(varargin{1});
end
if ~isempty(mess)
    error(mess)
end

% Make object
if nargout==0
    function_horace(file_internal,@cut,varargin{2:end});
else
    w=function_horace(file_internal,@cut,varargin{2:end});
end
