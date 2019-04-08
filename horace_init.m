function horace_init
% Adds the paths needed by Horace - sqw version
%
% In your startup.m, add the Horace root path and call horace_init, e.g.
%       addpath('c:\mprogs\horace')
%       horace_init
% Is PC and Unix compatible.

% T.G.Perring
%
%
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
% add sqw immediately after dnd classes
addpath_message (1,rootpath,'sqw');
addpath_message (1,rootpath,'algorithms');

% Add support package
addpath_message (1,rootpath,'herbert');

% DLL and configuration setup
addpath_message (2,rootpath,'DLL');
addpath_message (1,rootpath,'configuration');

% Other directories
addpath_message (1,rootpath,'horace_function_utils');
addpath_message (1,rootpath,'lattice_functions');
addpath_message (1,rootpath,'utilities');

% Functions for fitting etc.
addpath_message (1,rootpath,'functions');
addpath_message (1,rootpath,'sqw_models');

% Add GUI path
addpath_message(1,rootpath,'GUI');

% Add Tobyfit
addpath_message (1,rootpath,'Tobyfit');


% Set up graphical defaults for plotting
horace_plot.name_oned = 'Horace 1D plot';
horace_plot.name_multiplot = 'Horace multiplot';
horace_plot.name_stem = 'Horace stem plot';
horace_plot.name_area = 'Horace area plot';
horace_plot.name_surface = 'Horace surface plot';
horace_plot.name_contour = 'Horace contour plot';
horace_plot.name_sliceomatic = 'Sliceomatic';
set_global_var('horace_plot',horace_plot);

[~,Matlab_code,mexMinVer,mexMaxVer,date] = horace_version();
mc = [Matlab_code(1:48),'$)'];
hc = hor_config;

if hc.is_default
    if isempty(mexMaxVer)
        hc.use_mex = false;
    else
        hc.use_mex = true;
    end
%    % force saving default configuration if it has never been saved to hdd
%    % to avoid repetitive messages about default configuration
%    config_store.instance().store_config(hc,'-forcesave');
end



disp('!==================================================================!')
disp('!                      HORACE                                      !')
disp('!------------------------------------------------------------------!')
disp('!  Visualisation of multi-dimensional neutron spectroscopy data    !')
disp('!                                                                  !')
disp('!  R.A. Ewings, A. Buts, M.D. Le, J van Duijn,                     !')
disp('!  I. Bustinduy, and T.G. Perring                                  !')
disp('!                                                                  !')
disp('!  Nucl. Inst. Meth. A 834, 132-142 (2016)                         !')
disp('!                                                                  !')
disp('!  http://dx.doi.org/10.1016/j.nima.2016.07.036                    !')
disp('!------------------------------------------------------------------!')
disp(['! Matlab  code: ',mc,' !']);
if isempty(mexMaxVer)
    disp('! Mex code:    Disabled  or not supported on this platform         !')
else
    if mexMinVer==mexMaxVer
        mess=sprintf('! Mex files   : $Revision::%4d  $ (%s$) !',mexMaxVer,date(1:28));
    else
        mess=sprintf(...
            '! Mex files   :$Revisions::%4d-%3d(%s$)!',mexMinVer,mexMaxVer,date(1:28));
    end
    disp(mess)
    
end
disp('!------------------------------------------------------------------!')


%--------------------------------------------------------------------------
function addpath_message (type,varargin)
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
    if(type==1)
        path=genpath_special(string);
        addpath(path);
    else
        path=genpath_special(string);
        addpath(path);
    end
else
    warning('HORACE:init','"%s" is not a directory - not added to path',string)
end
