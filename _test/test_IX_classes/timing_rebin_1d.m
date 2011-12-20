function timing_rebin_1d (nx0, nw)
% Tests of timing of rebin in one dimension
%
%   >> timing_rebin_1d (nx0, nw)
%
%   nx0     Number of bins along x axis (approximately; used as input to generate data)
%   nw      Number of 1D workspaces in array odf IX_dataset_1d
%          (Type >> help make_IX_dataset_1d  for more details about nx0 and nw)
%
%   For timing tests, nx0=500, nw=500 are good values.

disp('Creating data for timing...')
[hh_1d_gau,hp_1d_gau,pp_1d_gau]=make_IX_dataset_1d (nx0, nw);
disp(' ')

% -----------------------------------------------
% Some timing tests with huge 1D arrays
% -----------------------------------------------
% With nx0=500; nw=500:
%    if point 'ave', then matlab and Fortran are comparable;
%    if point 'int', then matlab can be grossly more time-consuming
%                   for rebind(pp_1d_gau, [1,0.002,6],'int') is 30 times slower.
%                   (this is when the number of bins is comparable in the input and output dataset)

set(herbert_config,'force_mex_if_use_mex',true);
del=[0.1,0.01,0.002];
for i=1:numel(del)
    disp(['Rebin [1 (',num2str(del(i)),') 6]; point data with ''ave'', ''int''; histogram data; mixed data:'])
    disp('-----------------------------------------------------------------------------------')
    disp('- mex:')
    set(herbert_config,'use_mex',true);
    tic; wpa_ref=rebind(pp_1d_gau, [1,del(i),6],'ave'); toc
    tic; wpi_ref=rebind(pp_1d_gau, [1,del(i),6],'int'); toc
    tic; wh_ref =rebind(hh_1d_gau, [1,del(i),6]); toc
    tic; whp_ref=rebind(hp_1d_gau, [1,del(i),6]); toc
    disp('- matlab:')
    set(herbert_config,'use_mex',false);
    tic; wpa_mat=rebind(pp_1d_gau, [1,del(i),6],'ave'); toc
    tic; wpi_mat=rebind(pp_1d_gau, [1,del(i),6],'int'); toc
    tic; wh_mat =rebind(hh_1d_gau, [1,del(i),6]); toc
    tic; whp_mat=rebind(hp_1d_gau, [1,del(i),6]); toc
    disp(' ')
end
