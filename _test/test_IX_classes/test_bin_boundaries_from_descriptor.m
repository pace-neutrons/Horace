function test_bin_boundaries_from_descriptor
% Test equivalence of mex and matlab versions, and relative speed
%
%   >> test_bin_boundaries_from_descriptor
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% The function is in a private folder, so use tester:
tc = IX_dataset_tester();

% Simple equivalence tests
disp(' ')
disp('Test .m and mex equivalence with simple tests')
disp('---------------------------------------------')
xin=3:0.5:15;
xb{1}=[4,0.1,5];
xb{2}=[4,-0.1,5,0,8,0.25,12];
for i=1:numel(xb)
    xoutf=tc.bin_boundaries_from_descriptor(xb{i},xin,true,true);
    xoutm=tc.bin_boundaries_from_descriptor(xb{i},xin,false,true);
    [ok,mess]=equal_to_tol(xoutf,xoutm,-1e-14);
    assertTrue(ok,mess);
end
disp('Finished')
disp(' ')

% Timing test
disp('Get timings for large input arrays')
disp('----------------------------------')
nx=50000000;
xin=unique(nx*rand(1,nx)+0.1*(1:nx));
xb=[0,5,floor(nx/4),-0.01,floor(nx/2),0,floor(3*nx/4),10,nx];
disp('- Mex implementation:')
tic; xoutf=tc.bin_boundaries_from_descriptor(xb,xin,true,true); toc;
disp(' ')
disp('- Matlab implementation:')
tic; xoutm=tc.bin_boundaries_from_descriptor(xb,xin,false,true); toc;
disp(' ')
[ok,mess]=equal_to_tol(xoutf,xoutm,-1e-14);
assertTrue(ok,mess)


% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
