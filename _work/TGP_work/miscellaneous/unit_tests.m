function unit_tests(on_off)
% Enable or disable access to unit tests utilities
%
%   >> unit_tests('on')  or >> unit_tests on
%   >> unit_tests('off') or >> unit_tests off
%
%   >> unit_tests   % equivalent to >> unit_tests('on')

rootpath = fileparts(which('herbert_init'));
if nargin==0
    switch_on=true;
else
    if exist('on_off', 'var')
        if strcmpi(on_off,'off')
            switch_on=false;
        else
            switch_on=true;
        end
    else
        switch_on=true;
    end
end

% Enable or disable unit test utilities
xunit_path = fullfile(rootpath, '_test', 'shared', 'matlab_xunit','xunit');
if switch_on
    set(herbert_config,'init_tests', 1);
    addpath(xunit_path);
    cd(fullfile(rootpath,'_test'));
else
    set(herbert_config,'init_tests', 0);
    the_path=genpath_special(xunit_path);
    rmpath(the_path);
end
