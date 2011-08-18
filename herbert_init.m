function herbert_init (opt)
% Adds the paths needed by Herbert.
%
% In your startup.m, add the Herbert root path and call herbert_init, e.g.
%       addpath('c:\mprogs\herbert')
%       herbert_init
%
% Is PC and Unix compatible.

% T.G.Perring

% Get options
if exist('opt','var') && ~(ischar(opt) && size(opt,1)==1 && ~isempty(opt))
    error('Check option is character string')
elseif ~exist('opt','var')
    opt='fortran';
end

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

% Put mex files on path
if strcmpi(opt,'matlab')
    addgenpath_message (rootpath,'external_code','matlab')
else
    fortran_root = fullfile(rootpath,'external_code','Fortran');
    addpath_message (fortran_root);
    [mex_dir,mex_dir_full] = mex_dir_name(fortran_root);
    addpath_message (mex_dir_full);
end

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

%--------------------------------------------------------------------------
function [mex_dir,mex_dir_full] = mex_dir_name(fortran_root)
% Get directory for mex files, and the absolute path (NOT simply relative to rootpath)
if strcmpi(computer,'PCWIN64')
    mex_dir='x64';
    mex_dir_full=fullfile(fortran_root,'mex','x64');
elseif strcmpi(computer,'PCWIN')
    mex_dir='Win32';
    mex_dir_full=fullfile(fortran_root,'mex','Win32');
else
    error('Architecture type not supported yet')
end
