function aaa_test_all
% Runs all the test functions. Still need to be converted into true 
% unit and system tests

test_tobyfit_1 ('-test')
%test_tobyfit_1 ('-test','-legacy')

test_tobyfit_2 ('-test')

test_tobyfit_refine_crystal_1 ('-test')
%test_tobyfit_refine_crystal_1 ('-test','-legacy')

test_tobyfit_refine_moderator_1 ('-test')
%test_tobyfit_refine_moderator_1 ('-test','-legacy')

test_tobyfit_let_1 ('-test')

test_tobyfit_let_2 ('-test')

