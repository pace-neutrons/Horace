function test_bin_boundaries_from_descriptor
% Test equivalence of mex and matlab versions, and relative speed
%
%   >> test_bin_boundaries_from_descriptor

%cwd=pwd;    % Get current working directory

set(herbert_config,'force_mex_if_use_mex',true);
old_mex = get(herbert_config,'use_mex');
try
    % The function is in a private folder, so go to that location
    %cstr=which('bin_boundaries_from_descriptor','-all');
    %cd(fileparts(cstr{1}));
    
    % Simple equivalence tests
    disp(' ')
    disp('Test equivalence with simple tests')
    disp('----------------------------------')
    xin=3:0.5:15;
    xb{1}=[4,0.1,5];
    xb{2}=[4,-0.1,5,0,8,0.25,12];
    for i=1:numel(xb)
        xoutf=bin_boundaries_from_descriptor(xb{i},xin,true,true);
        xoutm=bin_boundaries_from_descriptor(xb{i},xin,false,true);
        assertElementsAlmostEqual(xoutf,xoutm);
    end
    disp('finished')
    disp(' ')
    
    % Timing test
    disp('Get timings for large input arrays')
    disp('----------------------------------')
    nx=50000000;
    xin=sort(nx*rand(1,nx)+0.1*(1:nx));
    xb=[0,5,floor(nx/4),-0.01,floor(nx/2),0,floor(3*nx/4),10,nx];
    disp('- Mex implementation:')
    tic; xoutf=bin_boundaries_from_descriptor(xb,xin,true,true); toc;
    disp(' ')
    disp('- Matlab implementation:')
    tic; xoutm=bin_boundaries_from_descriptor(xb,xin,false,true); toc;
    disp(' ')
    assertElementsAlmostEqual(xoutf,xoutm);
    %cd(cwd)
catch
    %cd(cwd);
    error(lasterr)
end
set(herbert_config,'force_mex_if_use_mex',false);    
set(herbert_config,'use_mex',old_mex);
