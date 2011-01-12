function w = read_horace(varargin)
% Read sqw or d0d/d1d/...d4d object from a file or array of objects from a set of files as appropriate to file contents
% 
%   >> w=read_horace            % prompts for file
%   >> w=read_horace(file)      % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Catch trivial case of sqw or dnd object
if nargin==1 && (isa(varargin{1},'sqw')||isa(varargin{1},'d0d')||isa(varargin{1},'d1d')||...
        isa(varargin{1},'d2d')||isa(varargin{1},'d3d')||isa(varargin{1},'d4d'))
    w=varargin{1};
    return
elseif nargin>=2
    error('Check number of arguments')
end

% Check file name(s), prompting if necessary
if nargin==0
    [file_internal,mess]=function_getfile('*.sqw;*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
else
    [file_internal,mess]=function_getfile(varargin{:});
end
if ~isempty(mess)
    error(mess)
end

% Make object
w=function_horace(file_internal,@read);
