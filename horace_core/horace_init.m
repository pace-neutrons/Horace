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
    error('Ensure Herbert is installed and initialized to run Horace. (Libisis is no longer supported)')
end
warning('off','MATLAB:subscripting:noSubscriptsSpecified');
% -----------------------------------------------------------------------------
% Root directory is assumed to be that in which this function resides
global horace_path
horace_path = fileparts(which('horace_init'));
global root_path
root_path = fileparts(horace_path);
addpath(horace_path)  % MUST have horace_path so that horace_init, horace_off included


% Add admin functions to the path first
addpath(fullfile(horace_path,'admin'));
% add sqw immediately after dnd classes
addpath_message (1,horace_path,'sqw');
addpath_message (1,horace_path,'algorithms');


% DLL and configuration setup
addpath_message (2,horace_path,'DLL');
%addpath_message (1,horace_path,'DLL/bin');
addpath_message (1,horace_path,'configuration');

% Other directories
addpath_message (1,horace_path,'horace_function_utils');
addpath_message (1,horace_path,'lattice_functions');
addpath_message (1,horace_path,'utilities');

% Functions for fitting etc.
addpath_message (1,horace_path,'functions');
addpath_message (1,horace_path,'sqw_models');

% Add GUI path
addpath_message(1,horace_path,'GUI');

% Add Tobyfit
addpath_message (1,horace_path,'Tobyfit');


% Set up graphical defaults for plotting
horace_plot.name_oned = 'Horace 1D plot';
horace_plot.name_multiplot = 'Horace multiplot';
horace_plot.name_stem = 'Horace stem plot';
horace_plot.name_area = 'Horace area plot';
horace_plot.name_surface = 'Horace surface plot';
horace_plot.name_contour = 'Horace contour plot';
horace_plot.name_sliceomatic = 'Sliceomatic';
set_global_var('horace_plot',horace_plot);

hc = hor_config;
check_mex = false;
if hc.is_default
    check_mex = true;
end

if hc.init_tests % this is developer version
    % set unit tests to the Matlab search path, to overwrite the unit tests
    % routines, added to Matlab after Matlab 2017b, as new routines have
    % signatures which are different from the standard unit tests routines.
    hc.set_unit_test_path();

    % add path to folders, which responsible for administrative operations
    addpath_message(1,fullfile(root_path,'admin'))
    addpath(fullfile(root_path,'_test','common_functions'));
end

hpcc = hpc_config;
if hc.is_default || hpcc.is_default
    warning([' Found Horace is not configured. ',...
        ' Setting up the configuration, identified as optimal for this type of the machine.',...
        ' Please, check configurations (typing:',...
        ' >>hor_config and >>hpc_config)',...
        ' to ensure these configurations are correct.'])
    % load and apply configuration, assumed to be optimal for this kind of the machine.
    conf_c = opt_config_manager();
    conf_c.load_configuration('-set_config','-change_only_default','-force_save');
end

if check_mex
    [~, n_mex_errors] = check_horace_mex();
    hc.use_mex = n_mex_errors < 1;
end

% Beta version: Suppress warning occurring when old instrument is stored in
% an sqw file and is automatically converted into MAPS
warning('off','SQW_FILE:old_version')

print_banner();

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


function print_banner()
width = 66;
lines = {
    ['Horace ', horace_version()], ...
    repmat('-', 1, width), ...
    'Visualisation of multi-dimensional neutron spectroscopy data', ...
    '', ...
    'R.A. Ewings, A. Buts, M.D. Le, J van Duijn,', ...
    'I. Bustinduy, and T.G. Perring', ...
    '', ...
    'Nucl. Inst. Meth. A 834, 132-142 (2016)', ...
    '', ...
    'http://dx.doi.org/10.1016/j.nima.2016.07.036',...
    repmat('-', 1, width), ...
    'If you found a bug or have technical problem with Horace,',...
    'please contact our team at HoraceHelp@stfc.ac.uk',...
    'Somebody will be back trying to help you.'...
    };
fprintf('!%s!\n', repmat('=', 1, width));
for i = 1:numel(lines)
    fprintf('!%s!\n', center_and_pad_string(lines{i}, ' ', width));
end
fprintf('!%s!\n', repmat('-', 1, width));
