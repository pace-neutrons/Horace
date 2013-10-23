function make_multifit_datasets_1
% Create some test data for testing multifit. Data written to tempdir with 
% name test_multifit_datasets_1.mat
%
% Creates the following:
%   x1, y1, e1      x,y,e arrays for a single Gaussian, with noise added
%   p1              Parameters for Gaussian on linear background used to generate
%   wstruct1        Structure with same arrays: fields are x, y, e
%   w1              IX_dataset_1d with the same data
%
% and same again, with names
%   x2,y2,e2,p2,wstruct2,w2
%   x3,y3,e3,p3,wstruct3,w3
%
% Author: T.G.Perring

output_file='c:\temp\test_multifit_datasets_1.mat';

p1=[110,45,  10,30,0.1];     % Gaussian 1
p2=[120,47.5,12,20,0.2];     % Gaussian 2
p3=[130,50,  15,10,0.3];     % Gaussian 3

x1=0:2:100 + 0.1*rand(1,100);
y1=mftest_gauss_bkgd(x1,p1);
e1=sqrt(y1);
[y1,e1]=noisify(y1,e1);
wstruct1=struct('x',x1,'y',y1,'e',e1);
w1=IX_dataset_1d(x1,y1,e1,'Test Gaussian 1','x-axis','signal');

x2=0:2:100 + 0.1*rand(1,100);
y2=mftest_gauss_bkgd(x2,p2);
e2=sqrt(y2);
[y2,e2]=noisify(y2,e2);
wstruct2=struct('x',x2,'y',y2,'e',e2);
w2=IX_dataset_1d(x2,y2,e2,'Test Gaussian 2','x-axis','signal');

x3=0:2:100 + 0.1*rand(1,100);
y3=mftest_gauss_bkgd(x3,p3);
e3=sqrt(y3);
[y3,e3]=noisify(y3,e3);
wstruct3=struct('x',x3,'y',y3,'e',e3);
w3=IX_dataset_1d(x3,y3,e3,'Test Gaussian 3','x-axis','signal');

save(output_file,'p1','x1','y1','e1','wstruct1','w1','p2','x2','y2','e2','wstruct2','w2','p3','x3','y3','e3','wstruct3','w3')
