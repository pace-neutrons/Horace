function herbert_init
% Adds the paths needed by Herbert.
%
% In your startup.m, add the Herbert root path and call herbert_init, e.g.
%       addpath('c:\mprogs\herbert')
%       herbert_init
%
% Is PC and Unix compatible.

% T.G.Perring


% Root directory is assumed to be that in which this function resides
% (keep this path, as may be removed by call to application_off)
rootpath = fileparts(which('herbert_init'));


% Remove all instances of Herbert
% -------------------------------
% (This might include this version of Herbert)
application_off('herbert');
warning('off','MATLAB:subscripting:noSubscriptsSpecified');
% if ~verLessThan('matlab','9.1')
%     warning('off','MATLAB:subscripting:noSubscriptsSpecified');
% end

% Add paths
% ---------
addpath(rootpath);  % MUST have rootpath so that herbert_init, herbert_off included
addpath(fullfile(rootpath,'admin'));

% Compatibility functions with Libisis, Mgenie
addgenpath_message (rootpath,'compatibility');

% Configurations
addgenpath_message (rootpath,'configuration');

% Class definitions, with methods and operator definitions
addgenpath_message (rootpath,'classes');

% Utilities definitions
addgenpath_message (rootpath,'utilities')

% Graphics
addgenpath_message (rootpath,'graphics')
genieplot_init

% Applications definitions
addgenpath_message (rootpath,'applications')

% Put mex files on path
addgenpath_message (rootpath,'DLL')

% set up multiusers computer specific settings,
% namely settings which are common for all new users of the specific computer
% e.g.:
hec = herbert_config();
parc = parallel_config();
if hec.is_default || parc.is_default
    warning(['Found Herbert is not configured. ',...
        ' Setting up the configuration, identified as optimal for this type of the machine.',...
        ' Please, check configurations (typing:',...
        ' >>herbert_config and ',...
        ' >>parallel_config)',...
        ' to ensure these configurations are correct.'])
    ocp = opt_config_manager();
    ocp.load_configuration('-set_config','-change_only_default','-force_save');
end
%

if hec.init_tests % this is developer vesion
    %
    %
    % set unit tests to the Matlab search path, to overwrite the unit tests
    % routines, added to Matlab after Matlab 2017b, as new routines have
    % signatures, different from the standard unit tests routines.
    hec.set_unit_test_path();
    % Add Herbert Matlab admin folders
    up_root = fileparts(rootpath);
    addgenpath_message(up_root,'admin');
    % copy github hooks
    copy_git_hooks('herbert');
end



disp('!==================================================================!')
disp('!         ISIS utilities for visualization and analysis            !')
disp('!              of neutron spectroscopy data                        !')
disp('!------------------------------------------------------------------!')


%=========================================================================================================
function addgenpath_message (varargin)
% Add a recursive toolbox path from the component directory names, printing
% a message if the directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\libisis','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:},'');    % '' needed to circumvent bug in fullfile if only one argument, Matlab 2008b (& maybe earlier)
if exist(string,'dir')==7
    try
        addpath (genpath_special(string),'-frozen');
    catch ME
        herbert_off
        rethrow(ME);
    end
else
    herbert_off
    error([string, ' is not a directory - not added to path']);
end

function application_off(app_name)
% Remove paths to all instances of the application.

start_dir=pwd;

% Determine the rootpaths of any instances of the application by looking for app_name on the matlab path
application_init_old = which([app_name,'_init'],'-all');

for i=1:numel(application_init_old)
    try
        rootpath=fileparts(application_init_old{i});
        cd(rootpath)
        if exist(fullfile(pwd,[app_name,'_off.m']),'file') % check that 'off' routine exists in the particular rootpath
            try
                feval([app_name,'_off'])    % call the 'off' routine
            catch ME
                message=ME.message;
                disp(['Unable to run function ',fullfile(pwd,[app_name,'_off.m']),'. Reason: ',message]);
            end
        else
            disp(['Function ',app_name,'_off.m not found in ',rootpath])
            disp('Clearing rootpath and subdirectories from Matlab path in any case')
        end
        paths = genpath(rootpath);
        warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
        rmpath(paths);
        warning(warn_state);    % return warnings to initial state
        cd(start_dir)           % return to starting directory
    catch ME
        cd(start_dir)           % return to starting directory
        message=ME.message;
        disp(['Problems removing ',rootpath,' and any sub-directories from matlab path. Reason: ',message]);
    end
end
