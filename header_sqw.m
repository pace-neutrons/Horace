function header_sqw(varargin)
% Display a summary of a file containing sqw information
% 
%   >> header_sqw           % prompts for file
%   >> header_sqw (file)
%
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


if nargin==1 && ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1    % is a single row of characters
    if (exist(varargin{1},'file')==2)
        file_internal = varargin{1};
    else
        file_internal = genie_getfile(varargin{1});
    end
elseif nargin==0
    file_internal = genie_getfile('*.sqw');
else
    error ('Input must be a file name')
end

if (isempty(file_internal))
    error ('No file given')
else
    [main_header,header,detpar,data,mess,position,npixtot,type]=sqw_get(file_internal,'-h');
    if ~isempty(mess); error(mess); end
    sqw_display_single (main_header,header,detpar,data,npixtot,type)
end
