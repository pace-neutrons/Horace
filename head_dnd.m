function varargout=head_dnd(varargin)
% Display a summary of a file or set of files containing sqw information
% 
%   >> head_dnd             % prompts for file
%   >> head_dnd (file)      % summary for named file or for cell array of file names
%
% To return header information in a structure
%   >> h = head_dnd
%   >> h = head_dnd (file)
%
%
% Gives the same information as display for an sqw object
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Catch case of dnd object, or sqw object (which will be treated as dnd object)
if nargin==1 && (isa(varargin{1},'d0d')||isa(varargin{1},'d1d')||...
        isa(varargin{1},'d2d')||isa(varargin{1},'d3d')||isa(varargin{1},'d4d'))
    if nargout==0
        head(varargin{1});
    else
        varargout{1}=head(varargin{1});
    end
    return
elseif nargin==1 && isa(varargin{1},'sqw')
    nd=dimensions(varargin{1}(1));
    for i=2:numel(varargin{1})
        if dimensions(varargin{1}(i))~=nd
            error('All dimensions of input sqw object must be equal to be treated as corresponding dnd object')
        end
    end
    if nargout==0
        head(dnd(varargin{1}));
    else
        varargout{1}=head(dnd(varargin{1}));
    end
    return
elseif nargin>=2
    error('Check number of arguments')
end

% Check file name(s), prompting if necessary
if nargin==0
    [file_internal,mess]=function_getfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
else
    [file_internal,mess]=function_getfile(varargin{:});
end
if ~isempty(mess)
    error(mess)
end

% Make object
if nargout==0
    function_dnd(file_internal,@head);
else
    varargout{1} = function_dnd(file_internal,@head);
end
