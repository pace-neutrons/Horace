function horace_init
% Adds the paths needed by Horace - sqw version
%
% In your startup.m, add the Horace root path and call horace_init, e.g.
%       addpath('c:\mprogs\horace')
%       horace_init
% Is PC and Unix compatible.

% T.G.Perring


disp('----------------------------------------------------------------')
disp('       Horace')
disp(' ====================')
disp('  Visualisation of multi-dimensional neutron spectroscopy data')
disp('')
disp('  T.G.Perring, J van Duijn, R.A.Ewings         November 2008')
disp('----------------------------------------------------------------')

% root directory is assumed to be that in which this function resides
rootpath = fileparts(which('horace_init'));
addpath(rootpath)  % MUST have rootpath so that horace_init, horace_off included

% Other directories
addpath_message (rootpath,'libisis');
addpath_message (rootpath,'utilities');

addpath_message (rootpath,'functions');
addpath_message (rootpath,'work_in_progress');
addpath_message (rootpath,'work_in_progress','Alex');

%Add GUI path - will be added in a later version of Horace
%addpath_message(rootpath,'GUI');

% Set up graphical defaults for Libisis plotting
IXG_ST_HORACE= struct('surface_name','Horace surface plot','area_name','Horace area plot','stem_name','Horace stem plot','oned_name','Horace one dimensional plot',...
    'multiplot_name','Horace multiplot','points_name','Horace 2d marker plot','contour_name','Horace contour plot','tag','Horace');
ixf_global_var('Horace','set','IXG_ST_HORACE',IXG_ST_HORACE);

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
