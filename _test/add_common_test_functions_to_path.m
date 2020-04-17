function common_funcs_path = add_common_test_functions_to_path()
% Add the _test/common_functions directory to the path

common_funcs_path = fullfile(horace_root(), '_test', 'common_functions');
addpath(common_funcs_path);
