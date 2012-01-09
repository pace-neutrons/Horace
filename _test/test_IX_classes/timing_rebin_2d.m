function timing_rebin_2d (nx, ny)
% Tests of timing of rebin in one dimension
%
%   >> timing_rebin_2d              % use default values for nx and ny
%   >> timing_rebin_2d (nx, ny)
%
%   nx          Number of x bin boundaries
%   ny          Number of y values
%          (Type >> help make_IX_dataset_2d  for more details)
%
%   For timing tests, nx0=5000, ny=3000 are good values. These are the defaults.

% Set default values for nx0 and nw
if nargin==0
    nx=5000; ny=3000;
elseif nargin==1
    ny=3000;
end

% Create test data sets
disp('Creating data for timing...')
[hh_gau,hp_gau,pp_gau] = make_IX_dataset_2d (nx, ny);
disp(' ')

% -----------------------------------------------
% Some timing tests with huge 2D arrays
% -----------------------------------------------
% With nx0=5000; ny0=3000: conclude Matlab and fortran are very similar.

set(herbert_config,'force_mex_if_use_mex',true);
del=[0.1,0.01,0.002];
for i=1:numel(del)
    disp(['Rebin [1 (',num2str(del(i)),') 6], [2 (',num2str(del(i)),') 4]; rebin option ''int'''])
    disp('-----------------------------------------------------------------------------------')
    disp('- mex:')
    set(herbert_config,'use_mex',true);
    tic; wmex=rebin(hp_gau,[1,del(i),6],[2,del(i),4],'int'); toc
    disp('- matlab:')
    set(herbert_config,'use_mex',false);
    tic; wmat=rebin(hp_gau,[1,del(i),6],[2,del(i),4],'int'); toc
    delta_IX_dataset_nd(wmex,wmat,-1e-14)
    disp(' ')
    disp(' ')
end

for i=1:numel(del)
    disp(['Rebin [1 (',num2str(del(i)),') 6], [2 (',num2str(del(i)),') 4]; rebin option ''int'''])
    disp('-----------------------------------------------------------------------------------')
    disp('- mex:')
    set(herbert_config,'use_mex',true);
    tic; wmex=rebin(hp_gau,[1,del(i),6],[2,del(i),4],'ave'); toc
    disp('- matlab:')
    set(herbert_config,'use_mex',false);
    tic; wmat=rebin(hp_gau,[1,del(i),6],[2,del(i),4],'ave'); toc
    delta_IX_dataset_nd(wmex,wmat,-1e-14)
    disp(' ')
    disp(' ')
end
