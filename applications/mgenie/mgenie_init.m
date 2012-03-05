function mgenie_init(mgenie_setup_file)
% Adds the paths needed by mgenie add-in routines.
%
% In your startup.m, add the mgenie_extras root path and call mgenie_extras_init, e.g.
%   addpath('c:\mprogs\calib')
%   mgenie_extras_init
%
% Is PC and Unix compatible.

% T.G.Perring

% Root directory is assumed to be that in which this function resides
rootpath = fileparts(which('mgenie_init'));
addpath(rootpath)  % MUST have rootpath so that mgenie_init, mgenie_off included

% Classes
addgenpath_message (rootpath,'classes');

% Functions required for compatibility with low level mgenie functions
addpath_message (rootpath,'compatibility');

% Extras with their own init routine
addpath_message (rootpath,'genie');
if nargin>0 && ~isempty(mgenie_setup_file)
    genie_init(mgenie_setup_file)
else
    genie_init
end

% Other directories
addpath_message (rootpath,'functions');

%--------------------------------------------------------------------------
function addpath_message (varargin)
% Add a path from the component directory names, printing a message if the
% directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\calib','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:},'');    % '' needed to circumvent bug in fullfile if only on argument, Matlab 2008b (& maybe earlier)
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

string=fullfile(varargin{:},'');    % '' needed to circumvent bug in fullfile if only on argument, Matlab 2008b (& maybe earlier)
if exist(string,'dir')==7
    addpath (genpath_special(string));
else
    warning('"%s" is not a directory - not added to path',string)
end
