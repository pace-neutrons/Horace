function horace_init
% Adds the paths needed by Horace - sqw version
%
% In your startup.m, add the Horace root path and call horace_init, e.g.
%       addpath('c:\mprogs\horace')
%       horace_init
% Is PC and Unix compatible.

% T.G.Perring
% $Revision$ ($Date$)

% -----------------------------------------------------------------------------
% Check if supporting Herbert package is available
if isempty(which('herbert_init'))
    error('Ensure Herbert is installed and initialised to run Horace. (Libisis is no longer supported)')
end
% -----------------------------------------------------------------------------
% Root directory is assumed to be that in which this function resides
rootpath = fileparts(which('horace_init'));
addpath(rootpath)  % MUST have rootpath so that horace_init, horace_off included

% Add admin functions to the path first
addpath(fullfile(rootpath,'admin'));

% Add support package
addpath_message (rootpath,'herbert');

% DLL and configuration setup
addpath_message (rootpath,'DLL');
addpath_message (rootpath,'configuration');

% Other directories
addpath_message (rootpath,'horace_function_utils');
addpath_message (rootpath,'lattice_functions');
addpath_message (rootpath,'utilities');

% Functions for fitting etc.
addpath_message (rootpath,'functions');

% Add GUI path
addpath_message (rootpath,'GUI');

% Add Tobyfit prototype
if ispc
    addpath_message (rootpath,'Tobyfit');
    tobyfit_init
end

% Set up graphical defaults for plotting
horace_plot.name_oned = 'Horace 1D plot';
horace_plot.name_multiplot = 'Horace multiplot';
horace_plot.name_stem = 'Horace stem plot';
horace_plot.name_area = 'Horace area plot';
horace_plot.name_surface = 'Horace surface plot';
horace_plot.name_contour = 'Horace contour plot';
horace_plot.name_sliceomatic = 'Sliceomatic';
set_global_var('horace_plot',horace_plot);

disp('!==================================================================!')
disp('!                      HORACE                                      !')
disp('!------------------------------------------------------------------!')
disp('!  Visualisation of multi-dimensional neutron spectroscopy data    !')
disp('!                                                                  !')
disp('!  T.G.Perring, J van Duijn, R.A.Ewings         November 2008      !')
disp('!------------------------------------------------------------------!')

if ~get(hor_config,'use_mex')
    [application,svn] = horace_version('mex_no_check');
    disp(['! Matlab code: ',svn.svn_version_str(1:48),'$)','  !']);
    disp( '!    Mex code: Currently not selected; using Matlab functions      !')
else
    [application,svn] = horace_version('full');
    disp(['! Matlab code: ',svn.svn_version_str(1:48),'$)','  !']);
    if svn.mex_ok
        if svn.mex_min_version==svn.mex_max_version
            mess=sprintf('! Mex files   : $Revision::%4d  $ (%s$) !',...
                svn.mex_min_version,svn.mex_last_compilation_date(1:28));
        else
            mess=sprintf(...
                '! Mex files   :$Revisions::%4d-%3d(%s$) !',...
                svn.mex_min_version,svn.mex_max_version,svn.mex_last_compilation_date(1:28));
        end
        disp(mess)
    else
        set(hor_config,'use_mex',0);
        disp( '!    Mex code: Disabled or not supported; using Matlab functions   !')
    end
end

disp('!------------------------------------------------------------------!')


%--------------------------------------------------------------------------
function addpath_message (varargin)
% Add a path from the component directory names, printing a message if the
% directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\libisis','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:},''); % '' is introduced for compartibility with
% Matlab 7.7 and probably below which has
% error in fullfile funtion called with
% one argument
if exist(string,'dir')==7
        path=genpath_special(string);
        addpath(path);
else
    warning('HORACE:init','"%s" is not a directory - not added to path',string)
end
