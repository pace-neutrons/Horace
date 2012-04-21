function aaa_test_setup (varargin)
% Setup tests for multifit
%
%   >> aaa_test_setup           % setup tests
%   >> aaa_test_setup('off')    % turn off tests
%
% Adds some folders to the path, or if the tests are turned off, removes them
% and sets force_mex_if_use_mex==false.

if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'off')
        on=false;
    else
        error('Unrecognised option')
    end
elseif nargin==0
    on=true;
else
    error('Check number of input arguments')
end

rootpath=fileparts(mfilename('fullpath'));

% Remove test paths
paths = genpath(rootpath);
warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent paths)
rmpath(paths);
warning(warn_state);    % return warnings to initial state

if on
    % Add test paths
    addpath(fullfile(rootpath,'make_data'));
end
