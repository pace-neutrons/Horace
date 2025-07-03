function herbert_init(no_banner)
% Adds the paths needed by Herbert.
%
% Optional input:
%
%  no_banner   -- if the variable is present, routine does not print the Herbert
%                 banner


% Root Herbert directory is assumed to be that in which this function resides
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

% Applications definitions
addgenpath_message (herbert_path,'applications')

if nargin == 0
    print_banner();
end

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
