function mtimes_bug
% Reveals that extracting a particular column from the product of two matricies
%    A=B*C 
% is not guaranteed to give the same result as multiplying the corresponding
% column of C by matrix B

% Load two arrays:
% - spec_to_u, a 3x3 double array
% - qspec, double array size 3x4640
load('mtimes_bug.mat','-mat')

% Multiplication of qspec by spec_to_u
var=spec_to_u*qspec;

% Compute column 4496 alone:
var_col=spec_to_u*qspec(:,4496);

% Element 2 of column 4496 is not computed to be the same: differs in last digit
format long
[var_col, var(:,4496)]
