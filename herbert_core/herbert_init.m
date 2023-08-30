function herbert_init
% Adds the paths needed by Herbert.
%
% In your startup.m, add the Horace root path and call horace_on, do not
% call this directly
%
% Is PC and Unix compatible.

% T.G.Perring


% Root directory is assumed to be that in which this function resides
% (keep this path, as may be removed by call to application_off)
global herbert_path
herbert_path = fileparts(which('herbert_init'));

warning('off','MATLAB:subscripting:noSubscriptsSpecified');

% Add paths
% ---------
addpath(herbert_path);  % MUST have herbert_path so that herbert_init, included
addpath(fullfile(herbert_path,'admin'));

% Configurations
addgenpath_message (herbert_path,'configuration');

% Class definitions, with methods and operator definitions
addgenpath_message (herbert_path,'classes');

% Utilities definitions
addgenpath_message (herbert_path,'utilities')

% Graphics
addgenpath_message (herbert_path,'graphics')
genieplot_init

% Applications definitions
addgenpath_message (herbert_path,'applications')

print_banner();

end

function addgenpath_message (varargin)
% Add a recursive toolbox path from the component directory names, printing
% a message if the directory does not exist.
% e.g.
%   >> addpath_message('c:\mprogs\my_app','bindings','matlab','classes')

% T.G.Perring

string=fullfile(varargin{:},'');    % '' needed to circumvent bug in fullfile if only one argument, Matlab 2008b (& maybe earlier)

if ~exist(string,'dir') == 7 % is_dir has not been loaded yet
    error('HERBERT:herbert_init:invalid_argument', '%s is not a directory - not added to path', string);
end

addpath (genpath_special(string),'-frozen');

end

function print_banner()
    width = 66;
    lines = {'ISIS utilities for visualization and analysis', ...
             'of neutron spectroscopy data', ...
             ['Herbert ', herbert_version()]
    };
    fprintf('!%s!\n', repmat('=', 1, width));
    for i = 1:numel(lines)
        fprintf('!%s!\n', center_and_pad_string(lines{i}, ' ', width));
    end
    fprintf('!%s!\n', repmat('-', 1, width));

end
