function tf_ver = determine_tobyfit_version
% Find version of Tobyfit
% Tobyfit2 and Tobyfit are mutually incompatible - Tobyfit only 

if ~isempty(which('tobyfit2_init')) && isempty(which('tobyfit_init'))
    tf_ver=2;
elseif ~isempty(which('tobyfit_init')) && isempty(which('tobyfit2_init'))
    tf_ver=1;
else
    error('Both or neither of Tobyfit and Tobyfit2 are present')
end
