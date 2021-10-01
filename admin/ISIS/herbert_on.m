function path = herbert_on(non_default_path)
% The function intended to switch Herbert on and
% return the path were Herbert is resided or
% empty string if Herbert has not been found
%
%
% The function has to be present in Matlab search path
% and modified for each machine to know default Herbert location
%
% The default Herbert location is the place where Herbert_init script
% can be found.
%
%Usage:
%>>path=herbert_on();
%       enables Herbert and initiates Herbert default search path
%>>path=herbert_on('where');
%       reports current location of Herbert or empty if not found
%
%>>path=herbert_on('a path');
%       initiates Herbert on non-default search path

default_herbert_path = 'C:\Users\nvl96446\STFC\git-230921\Herbert\herbert_core';

if exist('non_default_path','var') && (strcmpi(non_default_path,'where') || strcmpi(non_default_path,'which'))
    path = find_herbert_path(default_herbert_path);
    return;
end
if nargin == 1
    start_herbert(non_default_path);
else
    start_herbert(default_herbert_path);
end
path = fileparts(which('herbert_init.m'));

% -----------------------------------------------------------------------------
function start_herbert(path)
    addpath(path);
    herbert_init;

% -----------------------------------------------------------------------------
function path = find_herbert_path(default_herbert_path)
    path = which('herbert_init.m');
    if isempty(path)
        path = default_herbert_path;
        if ~exist(fullfile(path,'herbert_init.m'),'file')
            path = '';
        end
    else
        path=fileparts(path);
    end

