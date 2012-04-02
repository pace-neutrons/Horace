function make_test_data
% Create some test data for testing multifit with
%
% Creates the following:
%   x1, y1, e1      x,y,e arrays for a single Gaussian, with noise added
%   p1              Parameters for Gaussian on linear background used to generate
%   wstruct1        Structure with same arrays: fields are x, y, e
%   w1              IX_dataset_1d wioth the same data

output_file='c:\temp\test_mftest_datasets.mat';

p1=[110,45,10,30,0.1];     % Gaussian 1

x1=0:2:100 + 0.1*rand(1,100);
y1=mftest_gauss_bkgd(x1,p1);
e1=sqrt(y1);
[y1,e1]=noisify(y1,e1);

wstruct1=struct('x',x1,'y',y1,'e',e1);

w1=IX_dataset_1d(x1,y1,e1,'Test Gaussian 1','x-axis','signal');

save(output_file,'p1','x1','y1','e1','wstruct1','w1')
