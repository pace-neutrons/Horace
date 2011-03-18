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

% class definitions
addpath_message (rootpath,'classes','classdefs');

% Methods definitions
addpath_message (rootpath,'classes','methods');

% Operator definitions
addpath_message (rootpath,'classes','ops');

% Utilities definitions
addgenpath_message (rootpath, 'utilities')
% addpath_message (rootpath,'utilities','classes','classdefs');
% addpath_message (rootpath,'utilities','classes','ops');
% addpath_message (rootpath,'utilities','classes','methods');
% addpath_message (rootpath,'utilities','files');
% addpath_message (rootpath,'utilities','general');
% addpath_message (rootpath,'utilities','global_var');
% addpath_message (rootpath,'utilities','global_path');
% addpath_message (rootpath,'utilities','maths');
% addpath_message (rootpath,'utilities','misc');
% addpath_message (rootpath,'utilities','read_write');
% addpath_message (rootpath,'utilities','strings');

% Graphics
addpath_message (rootpath,'graphics')
addpath_message (rootpath,'graphics','test')

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
