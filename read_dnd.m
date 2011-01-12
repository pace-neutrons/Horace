function w = read_dnd(varargin)
% Read d0d, d1d, d2d, d3d or d4d object from a file, or an array of objects from a cell array of file names
% 
%   >> w=read_dnd           % prompts for file
%   >> w=read_dnd(file)     % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Catch trivial case of dnd object, or sqw object (which will be treated as dnd object)
if nargin==1 && (isa(varargin{1},'d0d')||isa(varargin{1},'d1d')||...
        isa(varargin{1},'d2d')||isa(varargin{1},'d3d')||isa(varargin{1},'d4d'))
    w=varargin{1};
    return
elseif nargin==1 && isa(varargin{1},'sqw')
    nd=dimensions(varargin{1}(1));
    for i=2:numel(varargin{1})
        if dimensions(varargin{1}(i))~=nd
            error('All dimensions of input sqw object must be equal to be treated as corresponding dnd object')
        end
    end
    w=dnd(varargin{1});
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
w=function_dnd(file_internal,@read);
