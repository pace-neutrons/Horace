function h=head_sqw(varargin)
% Display a summary of a file containing sqw information
% 
%   >> head_sqw           % prompts for file
%   >> head_sqw (file)
%
% To return header information in a structure
%   >> h = head_sqw
%   >> h = head_sqw (file)
%
%
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get filename
if nargin==1 && ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1    % is a single row of characters
    noffset=1;
    if (exist(varargin{1},'file')==2)
        file_internal = varargin{1};
    else
        file_internal = getfile(varargin{1});
    end
elseif nargin==0
    noffset=0;
    file_internal = getfile('*.sqw');
else
    error ('Input must be a file name')
end

% Make object
if nargout==0
    function_sqw(file_internal,@head,varargin{1+noffset:end});
else
    h = function_sqw(file_internal,@head,varargin{1+noffset:end});
end
