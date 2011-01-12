function varargout=head_horace(varargin)
% Display a summary of a file or set of files containing sqw information
% 
%   >> head_horace          % prompts for file
%   >> head_horace (file)   % summary for named file or for cell array of file names
%
% To return header information in a structure
%   >> h = head_horace
%   >> h = head_horace (file)
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


% Catch case of sqw object
if nargin==1 && (isa(varargin{1},'sqw')||isa(varargin{1},'d0d')||isa(varargin{1},'d1d')||...
        isa(varargin{1},'d2d')||isa(varargin{1},'d3d')||isa(varargin{1},'d4d'))
    if nargout==0
        head(varargin{1});
    else
        varargout{1}=head(varargin{1});
    end
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
if nargout==0
    function_horace(file_internal,@head);
else
    varargout{1} = function_horace(file_internal,@head);
end
