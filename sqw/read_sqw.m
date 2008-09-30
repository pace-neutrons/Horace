function data = read_sqw (varargin)
% Read data from a file containing sqw data. Will be a full sqw data structure, or Horace dnd (n=0...4) object
%
%   >> data = read_sqw                  % prompt for file, return Horace dnd object
%   >> data = read_sqw (file)           % give file, Horace dnd object returned
%
%   >> data = read_sqw (...,'-pix')     % as above, but return sqw structure
%
%
% Input:
%   file        [optional] Name of file from which to read the data
%   '-pix'      [optional] Return full sqw structure
%
% Output:
%   data        Horace dnd (n=0...4) object, or (if '-pix' option present) sqw data structure

% T.G.Perring 13 August 2007


% Check if last argument is '-pix' or an abbreviation of '-pix'
if nargin>0 && ischar(varargin{end}) && size(varargin{end},1)==1 && strncmpi(varargin{end},'-pix',max(length(varargin{end}),2))
    read_pix=true;
else
    read_pix=false;
end

if nargin-read_pix==0
    file='';
elseif nargin-read_pix==1
    file=varargin{1};
else
    error('Check number and type of arguments')
end
    
% Get file name - prompting if necessary
if ~isempty(file)
    if (exist(file,'file')==2)
        file_internal = file;
    else
        file_internal = genie_getfile(file);
    end
else
    file_internal = genie_getfile('*.sqw');
end
if (isempty(file_internal))
    error ('No file given')
end

% Read data from file
if read_pix
    disp(['Reading sqw data structure from ',file_internal,'...'])
    [data.main_header,data.header,data.detpar,data.data,mess]=get_sqw(file_internal);
    if ~isempty(mess); error(mess); end
else
%     disp(['Reading Horace dnd (n=0...4) object from ',file_internal,'...'])
    [data.main_header,data.header,data.detpar,data.data,mess]=get_sqw(file_internal,'-nopix');
    if ~isempty(mess); error(mess); end
    data = sqw_to_dnd(data);
end
