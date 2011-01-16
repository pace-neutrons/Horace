function varargout=head_sqw(varargin)
% Display a summary of a file or set of files containing sqw information
% 
%   >> head_sqw             % prompts for file
%   >> head_sqw (file)      % summary for named file or for cell array of file names
%
% To return header information in a structure
%   >> h = head_sqw        
%   >> h = head_sqw (file)
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
if nargin==1 && isa(varargin{1},'sqw')
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
    [file_internal,mess]=getfile_horace('*.sqw');
else
    [file_internal,mess]=getfile_horace(varargin{:});
end
if ~isempty(mess)
    error(mess)
end

% Make object
if nargout==0
    function_sqw(file_internal,@head);
else
    varargout{1} = function_sqw(file_internal,@head);
end
