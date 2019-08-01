function create_testdata_multifit_1
% Create some test data for testing multifit. Data written to tempdir with 
% name testdata_multifit_1.mat
%
% Creates the following:
%   p1              Parameters for Gaussian on linear background used to generate
%   x1, y1, e1      x,y,e arrays for a single Gaussian, with noise added
%   c1              Cell array {x1,y1,e1}
%   s1              Structure with same arrays: fields are x, y, e
%   w1              IX_dataset_1d with the same data
%
% and same again, with names
%   x2,y2,e2,p2,wstruct2,w2
%   x3,y3,e3,p3,wstruct3,w3
%
% Author: T.G.Perring

output_file=fullfile(tempdir,'testdata_multifit_1.mat');

p1=[110,52.5,10  ,30,0.1];     % Gaussian 1
p2=[120,55,  12.5,20,0.2];     % Gaussian 2
p3=[130,57.5,15  ,10,0.3];     % Gaussian 3

x1=-10:2:90;
x1=x1 + 0.1*rand(size(x1));
y1=mftest_gauss_bkgd(x1,p1);
e1=sqrt(y1);
[y1,e1]=noisify(y1,e1);
c1 = {x1,y1,e1};
s1=struct('x',x1,'y',y1,'e',e1);
w1=IX_dataset_1d(x1,y1,e1,'Test Gaussian 1','x-axis','signal');

x2=0:2:110;
x2=x2 + 0.1*rand(size(x2));
y2=mftest_gauss_bkgd(x2,p2);
e2=sqrt(y2);
[y2,e2]=noisify(y2,e2);
s2=struct('x',x2,'y',y2,'e',e2);
c2 = {x2,y2,e2};
w2=IX_dataset_1d(x2,y2,e2,'Test Gaussian 2','x-axis','signal');

x3=10:2:130;
x3=x3 + 0.1*rand(size(x3));
y3=mftest_gauss_bkgd(x3,p3);
e3=sqrt(y3);
[y3,e3]=noisify(y3,e3);
c3 = {x3,y3,e3};
s3=struct('x',x3,'y',y3,'e',e3);
w3=IX_dataset_1d(x3,y3,e3,'Test Gaussian 3','x-axis','signal');

save(output_file,...
    'p1','x1','y1','e1','c1','s1','w1',...
    'p2','x2','y2','e2','c2','s2','w2',...
    'p3','x3','y3','e3','c3','s3','w3')
