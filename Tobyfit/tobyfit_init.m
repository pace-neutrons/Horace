function tobyfit_init
% Adds the paths needed by named application routines.
%
% Is PC and Unix compatible.

% T.G.Perring

% root directory is assumed to be that in which this function resides
rootpath = fileparts(which(mfilename));
addpath(rootpath)  % MUST have rootpath so that xxx_init, xxx_off included

% Other directories
% -----------------
% Put m-files that do the mexing on the path
%addpath_message (rootpath,'mtimesx')


%=========================================================================================================
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

%=========================================================================================================
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
