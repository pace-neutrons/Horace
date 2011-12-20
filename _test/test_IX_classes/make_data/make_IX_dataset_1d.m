function [hh_1d_gau,hp_1d_gau,pp_1d_gau]=make_IX_dataset_1d (nx0, nw)
% Create arrays of IX_dataset_1d with random x axes and Gaussian signal
%
%   >> [hh_1d_gau,hp_1d_gau,pp_1d_gau]=make_IX_dataset_1d (nx0, nw)
%
% Input:
% -------
%   nx0                 Used to generate values of points along the x axis. Each
%                      IX_dataset_1d will have approximately nx0 points, with
%                      values approximately between 0 and 10.
%   nw                  Number of workspaces in the output IX_dataset_1d arrays
%
% Output:
% -------
%   hh_1d_gau           Array of nw IX_dataset_1d objects, all with different x, signal error
%                      arrays, mixed histogram and point datasets. The x arrays have
%                      different lengths, but are approximately on the range 0-10.
%                       The Gaussians correspond to an overall 2D Gaussian centred on x=5
%                      and the middle workspace number i.e. nw/2
%   hp_1d_gau           hist-point (different x,y,signal and errors)
%   pp_1d_gau           point-point (different x,y,signal and errors)



xrange=10;

% A big point array
% ------------------------------
tic
nx=nx0+round(0.2*nx0*rand(nw,1));
pp_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    pp_1d_gau(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc

% A big histogram array
% ------------------------------
tic
nx=nx0+round(0.2*nx0*rand(nw,1));
hh_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    hh_1d_gau(i)=IX_dataset_1d(x,y,e,'Point data, not distribution',IX_axis('Energy transfer','meV','$w'),'Counts',false);
end
toc

% A big mixed histogram and point array
% -------------------------------------
tic
nx=nx0+round(0.2*nx0*rand(nw,1));
hp_1d_gau=repmat(IX_dataset_1d,nw,1);
for i=1:nw
    x=xrange*((1+0.1*rand(1,1))*sort(rand(1,nx(i)))-0.05*rand(1,1));
    y=10*exp(-0.5*(((x-xrange/2)/(xrange/4)).^2 + ((i-nw/2)/(nw/4)).^2));
    e=0.5+rand(1,nx(i));
    dn=round(rand(1));
    hp_1d_gau(i)=IX_dataset_1d(x,y(1:end-dn),e(1:end-dn),'Point data, distribution',IX_axis('Energy transfer','meV','$w'),'Counts',true);
end
toc




% % -----------------------------------------------
% % Some timing tests with huge 1D arrays
% % -----------------------------------------------
% % With nx0=500; nw=500:
% %    if point 'ave', then matlab and Fortran are comparable;
% %    if point 'int', then matlab can be grossly more time-consuming
% %                   for rebind(p_1d_huge, [1,0.002,6],'int') is 30 times slower.
% %                   (this is when the number of bins is comparable in the input and output dataset)
% del=[0.1,0.01,0.002];
% for i=1:numel(del)
%     disp(['Del=',num2str(del(i))])
%     use_mex(true)
%     disp('- fortran:')
%     tic; wpa_ref=rebind(pp_1d_huge, [1,del(i),6],'ave'); toc
%     tic; wpi_ref=rebind(pp_1d_huge, [1,del(i),6],'int'); toc
%     tic; wh_ref =rebind(hh_1d_huge, [1,del(i),6]); toc
%     tic; whp_ref=rebind(hp_1d_huge,[1,del(i),6]); toc
%     use_mex(false)
%     disp('- matlab:')
%     tic; wpa_mat=rebind(pp_1d_huge, [1,del(i),6],'ave'); toc
%     tic; wpi_mat=rebind(pp_1d_huge, [1,del(i),6],'int'); toc
%     tic; wh_mat =rebind(hh_1d_huge, [1,del(i),6]); toc
%     tic; whp_mat=rebind(hp_1d_huge,[1,del(i),6]); toc
% end
% 
% 
% 
% % -----------------------------------------------
% % Some timing tests with huge 2D arrays
% % -----------------------------------------------
% % With nx0=5000; ny0=3000: conclude Matlab is about 40% faster!
% del=[0.1,0.01,0.002];
% for i=1:numel(del)
%     use_mex(true)
%     tic; wref=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'int'); toc
%     use_mex(false)
%     tic; wmat=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'int'); toc
%     delta_IX_dataset_nd(wref,wmat,-1e-14)
% end
% % Elapsed time is 0.952300 seconds.
% % Elapsed time is 0.456290 seconds.
% % Elapsed time is 1.288882 seconds.
% % Elapsed time is 0.797968 seconds.
% % Elapsed time is 3.029477 seconds.
% % Elapsed time is 1.960267 seconds.
% for i=1:numel(del)
%     use_mex(true)
%     tic; wref=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'ave'); toc
%     use_mex(false)
%     tic; wmat=rebind(hp_huge,[1,del(i),6],[2,del(i),4],'ave'); toc
%     delta_IX_dataset_nd(wref,wmat,-1e-14)
% end
% % Elapsed time is 0.928720 seconds.
% % Elapsed time is 0.481735 seconds.
% % Elapsed time is 1.305833 seconds.
% % Elapsed time is 0.790645 seconds.
% % Elapsed time is 2.855406 seconds.
% % Elapsed time is 1.887153 seconds.
% 
% 
% 
