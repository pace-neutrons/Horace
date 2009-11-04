function horace_init
% Adds the paths needed by Horace - sqw version
%
% In your startup.m, add the Horace root path and call horace_init, e.g.
%       addpath('c:\mprogs\horace')
%       horace_init
% Is PC and Unix compatible.

% T.G.Perring
% $Revision$ ($Date$)
%
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

addpath_message (2,rootpath,'DLL');

% Other directories
addpath_message (1,rootpath,'libisis');
addpath_message (1,rootpath,'utilities');
%
addpath_message (1,rootpath,'functions');
addpath_message (1,rootpath,'work_in_progress');
%
%Add GUI path - will be added in a later version of Horace
%addpath_message(rootpath,'GUI');

% Set up graphical defaults for Libisis plotting
IXG_ST_HORACE= struct('surface_name','Horace surface plot','area_name','Horace area plot','stem_name','Horace stem plot','oned_name','Horace one dimensional plot',...
    'multiplot_name','Horace multiplot','points_name','Horace 2d marker plot','contour_name','Horace contour plot','tag','Horace');
ixf_global_var('Horace','set','IXG_ST_HORACE',IXG_ST_HORACE);

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
      path=genpath(string);
    else
      path=gen_Libisis_path(string);
    end
else
    warning('"%s" is not a directory - not added to path',string)
end
