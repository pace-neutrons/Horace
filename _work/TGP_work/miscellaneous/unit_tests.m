function unit_tests(on_off)
% Enable or disable access to unit tests utilites
%
%   >> unit_tests('on')  or >> unit_tests on
%   >> unit_tests('off') or >> unit_tests off
%
%   >> unit_tests   % equivalent to >> unit_tests('on')

rootpath = fileparts(which('herbert_init'));
if nargin==0
    switch_on=true;
else
    if exist('on_off','var')
        if strcmpi(on_off,'off')
            switch_on=false;
        else
            switch_on=true;
        end
    else
        switch_on=true;
    end
end

% Enable or disable unit test utilites
if switch_on
    set(herbert_config,'init_tests',1);
    addpath(fullfile(rootpath,'_test/matlab_xunit/xunit'));
    cd(fullfile(rootpath,'_test'));
else
    set(herbert_config,'init_tests',0);
    the_path=genpath_special(fullfile(rootpath,'_test/matlab_xunit/xunit'));
    rmpath(the_path);
end
