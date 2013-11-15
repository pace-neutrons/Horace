function run_unit_tests()
test_path=set_unit_test();

runtests test_Hor_libisis

rmpath(test_path)


function test_path=set_unit_test()
root= fileparts(which('horace_init.m'));
test_path = fullfile(root,'test','matlab_xunit','xunit');
addpath(test_path);
