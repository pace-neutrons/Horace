function horace_init
% Adds the paths needed by Horace - sqw version
%
% In your startup.m, add the Horace root path and call horace_init, e.g.
%       addpath('c:\mprogs\horace')
%       horace_init
% Is PC and Unix compatible.

% T.G.Perring
% $Revision$ ($Date$)

% Root directory is assumed to be that in which this function resides
rootpath = fileparts(which('horace_init'));
addpath(rootpath)  % MUST have rootpath so that horace_init, horace_off included

addpath_message (2,rootpath,'DLL');

addpath_message (1,rootpath,'libisis');
% If Herbert is present, choose Herbert graphics functions and methods ahead of libisis functions
if ~isempty(which('herbert_init'))
    addpath_message (1,rootpath,'herbert');
end

% Other directories
addpath_message (1,rootpath,'utilities');
addpath_message (1,rootpath,'functions');
%addpath_message (1,rootpath,'hdf_tools');

%Add GUI path
addpath_message(1,rootpath,'GUI');

addpath_message (1,rootpath,'configuration');

%addpath_message (1,rootpath,'work_in_progress');   % not included in the distribution


% Set up graphical defaults for plotting
try
    % For Herbert:
    horace_plot.name_oned = 'Horace 1D plot';
    horace_plot.name_multiplot = 'Horace multiplot';
    horace_plot.name_stem = 'Horace stem plot';
    horace_plot.name_area = 'Horace area plot';
    horace_plot.name_surface = 'Horace surface plot';
    horace_plot.name_contour = 'Horace contour plot';
    horace_plot.name_sliceomatic = 'Sliceomatic';
    set_global_var('horace_plot',horace_plot);
catch
    % For libisis:
    IXG_ST_HORACE= struct('surface_name','Horace surface plot','area_name','Horace area plot','stem_name','Horace stem plot','oned_name','Horace one dimensional plot',...
        'multiplot_name','Horace multiplot','points_name','Horace 2d marker plot','contour_name','Horace contour plot','tag','Horace');
    ixf_global_var('Horace','set','IXG_ST_HORACE',IXG_ST_HORACE);
end

[application,Matlab_code,mexMinVer,mexMaxVer,date] = horace_version();
mc = [Matlab_code(1:48),'$)'];
disp('!------------------------------------------------------------------!')
disp('!                    HORACE                                        !')
disp('! =================================================================!')
disp('!  Visualisation of multi-dimensional neutron spectroscopy data    !')
disp('!                                                                  !')
disp('!  T.G.Perring, J van Duijn, R.A.Ewings         November 2008      !')
disp('!------------------------------------------------------------------!')
disp(['! Matlab  code: ',mc,' !']);
if isempty(mexMaxVer)
    disp('! Mex code:    Disabled  or not supported on this platform         !')
else
    if mexMinVer==mexMaxVer
        mess=sprintf('! Mex files   : $Revision::%4d  $ (%s$) !',mexMaxVer,date(1:28));
    else
        mess=sprintf(...
            '! Mex files   :$Revisions::%4d-%3d(%s$) !',mexMinVer,mexMaxVer,date(1:28));
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
        path=genpath_(string);
        addpath(path);
    else
        path=gen_System_path(string);
        addpath(path);
    end
else
    warning('HORACE:init','"%s" is not a directory - not added to path',string)
end
