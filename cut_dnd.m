function w = cut_dnd(varargin)
% Take a cut from a file containing sqw or d0d/d1d/...d4d object, as appropriate to file contents.
% If data is sqw-type i.e. has pixel information, this is ignored and is treated as equivalent
% d0d, d1d,...d4d object.
%
% Syntax:
%   >> w=cut_dnd (file, arg1, arg2, ...)    % dnd data in named file, or cell array of filenames
%                                           % Output is an array if given cell array of files
%
% For full details of arguments for cut method, type:
%
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Catch case of dnd object, or sqw object (which will be treated as dnd object)
if nargin>=1 && (isa(varargin{1},'d0d')||isa(varargin{1},'d1d')||...
        isa(varargin{1},'d2d')||isa(varargin{1},'d3d')||isa(varargin{1},'d4d'))
    if nargout==0
        cut(varargin{:});
    else
        w=cut(varargin{:});
    end
    return
elseif nargin>=1 && isa(varargin{1},'sqw')
    nd=dimensions(varargin{1}(1));
    for i=2:numel(varargin{1})
        if dimensions(varargin{1}(i))~=nd
            error('All dimensions of input sqw object must be equal to be treated as corresponding dnd object')
        end
    end
    if nargout==0
        cut(dnd(varargin{1}),varargin{2:end});
    else
        w=cut(dnd(varargin{1}),varargin{2:end});
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
    function_dnd(file_internal,@cut,varargin{2:end});
else
    w=function_dnd(file_internal,@cut,varargin{2:end});
end
