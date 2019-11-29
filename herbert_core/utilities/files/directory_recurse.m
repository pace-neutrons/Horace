function directory_recurse(directory, varargin)
% Recurse through sub-directories executing function pointer.
% Based on directory_recurse, Rodney Thomson (http://iheartmatlab.blogspot.com)
% 
%   >> directory_recurse (root_directory, @function_pointer, arg1, arg2, ...)
%   >> directory_recurse (root_directory, include, @function_pointer, arg1, arg2, ...)
%   >> directory_recurse (root_directory, include, exclude, @function_pointer, arg1, arg2, ...)
%
%
%   root_directory      Top level directory from which to begin recursion
%   include             List of directory names to include (default: all)
%                       Format: e.g. 'temp', 'te*; *mat*'
%                       If empty, then uses default
%   exclude             List of directory names to exclude (default: none)
%                       Format: e.g. 'temp', 'te*; *mat*'
%                       If empty, then uses default
%   function_pointer    Pointer to function to execute in each directory,
%                       with each directory as its first argument
%   arg1, arg2, ...     Additional arguments to pass to function pointer
%
%   e.g.
%   >> directory_recurse('c:\tmp', @rmdir, 's')
%
%   >> directory_recurse('c:\temp', 'dat;*mat*', 'data', @rmdir, 's')

% Find function_handle and include/exclude directories
if nargin>=1 && isa(varargin{1},'function_handle')
    include='';
    exclude='';
    function_pointer=varargin{1};
    iargbeg=2;
elseif nargin>=2 && isa(varargin{2},'function_handle')
    include=varargin{1};
    exclude='';
    function_pointer=varargin{2};
    iargbeg=3;
elseif nargin>=3 && isa(varargin{3},'function_handle')
    include=varargin{1};
    exclude=varargin{2};
    function_pointer=varargin{3};
    iargbeg=4;
else
    error('Check number of input arguments')
end

% Check input directory exists
if ~exist(directory,'dir')
    error(['Input root directory does not exist: ',directory])
end

% Get list of all directories to search
directories=dir_name_list(directory, include, exclude);

% Loop over all directories
for i=1:numel(directories)
    sub_directory=directories{i};
    % ignore '.' and '..'
    if (strcmp(sub_directory,'.') || strcmp(sub_directory,'..'))
        continue;
    end
    % Recurse down
    full_directory=fullfile(directory,sub_directory);
    directory_recurse(full_directory, include, exclude, function_pointer, varargin{iargbeg:end});
end

% execute the callback with any supplied parameters.
% Due to recursion will execute in a bottom up manner
function_pointer(directory, varargin{iargbeg:end});
