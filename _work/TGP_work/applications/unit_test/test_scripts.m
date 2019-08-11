%% sub functions
% ----------------

% Works in 2014a but not 2016b: see xunit4 on fileexchange for some notes

cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test
runtests sub_function_test  % should run four tests

cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_function_test
runtests testFliplr_A       % shoudl run the two tests in the function

cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_function_test
runtests testFliplr_A:testFliplrMatrix_A    % shoudl run just the one test, a subfunction


cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test
addpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_function_test')
runtests testFliplr_A:testFliplrMatrix_A    % shoudl run just the one test, a subfunction
rmpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_function_test')





%% functions
% ---------------

cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\function_test
runtests testFliplrMatrix2


cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test
addpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\function_test')
runtests testFliplrMatrix2    % shoudl run just the one test, a subfunction
rmpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\function_test')




%% Subclass
% --------------
cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test
addpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_class_test')
runtests myTestUsingTestCase    % shoudl run two tests
rmpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_class_test')


cd T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test
addpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_class_test')
runtests myTestUsingTestCase:testPointer    % shoudl run one test
rmpath('T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\unit_test\sub_class_test')





