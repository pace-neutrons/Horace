function herbert_init
% Adds the paths needed by Herbert.
%
% In your startup.m, add the Herbert root path and call herbert_init, e.g.
%       addpath('c:\mprogs\herbert')
%       herbert_init
%
% Is PC and Unix compatible.

% T.G.Perring

% root directory is assumed to be that in which this function resides
rootpath = fileparts(which('herbert_init'));
addpath(rootpath)  % MUST have rootpath so that herbert_init, herbert_off included

% Class definitions, with methods and operator definitions
addgenpath_message (rootpath,'classes');

% Utilities definitions
addgenpath_message (rootpath, 'utilities')

% Graphics
addgenpath_message (rootpath,'graphics')
genieplot_init

% Applications definitions
addgenpath_message (rootpath, 'applications')


%--------------------------------------------------------------------------
function addpath_message (varargin)
% Add a path from the component directory names, printing a message if the
% directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\libisis','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:});
if exist(string,'dir')==7
    addpath (string);
else
    warning('"%s" is not a directory - not added to path',string)
end

%--------------------------------------------------------------------------
function addgenpath_message (varargin)
% Add a recursive toolbox path from the component directory names, printing
% a message if the directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\libisis','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:});
if exist(string,'dir')==7
    addpath (genpath_special(string));
else
    warning('"%s" is not a directory - not added to path',string)
end
