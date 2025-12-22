function validate_horace_test_stage_reset(icount, hor, hpc, par, nomex, forcemex, talkative)
% Set Horace configurations to the defaults (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)

% Set the default configurations, printing warning only the first time round to
% avoid copious warning messages
warn_state = warning();
cleanup_obj = onCleanup(@()warning(warn_state));
if icount>1
    warning('off',  'all');
end

set(hor, 'defaults');
set(hpc, 'defaults');
% set(par, 'defaults');

% Return warning state to incoming state
warning(warn_state)

% Special unit tests settings.
hor.init_tests = true; % initialise unit tests
hor.use_mex = ~nomex;
hor.force_mex_if_use_mex = forcemex;

if talkative
    hor.log_level = 1; % force log level high.
else
    hor.log_level = -1; % turn off informational output
end

end
