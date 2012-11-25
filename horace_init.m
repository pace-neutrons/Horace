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

% Add admin functions to the path first
addpath(fullfile(rootpath,'admin'));

% Select supporting package on basis of what is currently initiated/requested
% and check if supporting package is available
select_supporting_package(rootpath);

% DLL and configuration setup
addpath_message (2,rootpath,'DLL');
addpath_message (1,rootpath,'configuration');

% Other directories
addpath_message (1,rootpath,'lattice_functions');
addpath_message (1,rootpath,'utilities');

% Functions for fitting etc.
addpath_message (1,rootpath,'functions');

%Add GUI path
addpath_message(1,rootpath,'GUI');

%addpath_message (1,rootpath,'work_in_progress');   % not included in the distribution


% Set up graphical defaults for plotting
if  is_herbert_used()
    % For Herbert:
    horace_plot.name_oned = 'Horace 1D plot';
    horace_plot.name_multiplot = 'Horace multiplot';
    horace_plot.name_stem = 'Horace stem plot';
    horace_plot.name_area = 'Horace area plot';
    horace_plot.name_surface = 'Horace surface plot';
    horace_plot.name_contour = 'Horace contour plot';
    horace_plot.name_sliceomatic = 'Sliceomatic';
    set_global_var('horace_plot',horace_plot);
else
    % For libisis:
    IXG_ST_HORACE= struct('surface_name','Horace surface plot','area_name','Horace area plot','stem_name','Horace stem plot','oned_name','Horace one dimensional plot',...
        'multiplot_name','Horace multiplot','points_name','Horace 2d marker plot','contour_name','Horace contour plot','tag','Horace');
    ixf_global_var('Horace','set','IXG_ST_HORACE',IXG_ST_HORACE);
end

[application,Matlab_code,mexMinVer,mexMaxVer,date] = horace_version();
mc = [Matlab_code(1:48),'$)'];

disp('!==================================================================!')
disp('!                      HORACE                                      !')
disp('!------------------------------------------------------------------!')
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

function select_supporting_package(rootpath)
% function chooses between herbert and Libisis as function 
% of what was initiated or initiated last (first on the search path)

herb_path=which('herbert_init');
libs_path=which('libisis_init');

herb_defined=true;
if isempty(herb_path)
    herb_defined=false;
end
libs_defined=true;
if isempty(libs_path)
    libs_defined=false;    
end

% if found both identify who is higher on the search path to use it.
if herb_defined&&libs_defined 
    herb_pattern = fileparts(herb_path);
    libs_pattern = fileparts(libs_path);
    iherb = strfind(path,herb_pattern);
    ilibs = strfind(path,libs_pattern);
    
    if isempty(iherb)&&isempty(ilibs)
        error('horace_init:Logic_error','Herbert and Libisis are identified as initiated but can not be found on search path'); 
    end
    % we may be in herbert or libisis folder but the package is not on the path
    if isempty(iherb)||isempty(ilibs)
        % herbert is not present, but let's pretent that it is present 
        % and is behind libisis
        if isempty(iherb)&&(~isempty(ilibs))
            iherb=ilibs(1)+10; 
        end
        % libisis is not present, but let's pretent that it is present 
        % and is behind herbert for next statement to work       
        if isempty(ilibs)&&(~isempty(iherb))
            ilibs=iherb(1)+10; 
        end
        
    end
    if iherb(1)<ilibs(1)
        herb_defined=true;
        libs_defined=false;
        warning('horace_init:package_selection','Herbert and Libisis found on the search path; will use Herbert');
        disp(' use use_herbert ''off'' to switch to use Libisis');
    else
        herb_defined=false;
        libs_defined=true;       
        warning('horace_init:package_selection','Herbert and Libisis found on the search path; Will use Libisis');
        disp(' use use_herbert ''on'' to switch to use Herbert');
        
    end
end

% select herbert/libisis supporting packages as function of what is
% availible/first on the path.
if herb_defined
    addpath_message (1,rootpath,'herbert');
elseif libs_defined
    addpath_message (1,rootpath,'libisis');    
else
    horace_off();
    error('horace_init:package_selection','either Libisis or Herbert have to be initated before intiating Horace');    
end

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
