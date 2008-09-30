% =====================================================================================================================
% Script to create sqw file
% =====================================================================================================================
indir='D:\Fe\data_nov06\const_ei\';     % source directory of spe files
par_file='D:\fe\9cards_4_4to1.par';     % detector parameter file
sqw_file='E:\fe\fe787\fe_2.sqw';        % output sqw file

efix=787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

% psi=0(-0.5)-23 runs 11014->11060
% -----------------------------------
nfiles1=47;
psi1=linspace(0,-0.5*(nfiles1-1),nfiles1);
spe_file1=cell(1,nfiles1);
for i=1:length(psi1)
    spe_file1{i}=[indir,'map',num2str(11013+i),'.spe;1'];
end

% psi=-23.5(-0.5)-92.5 runs 11063->11201
% ---------------------------------------
nfiles2=139;
psi2=linspace(-23.5,-23.5-0.5*(nfiles2-1),nfiles2);
spe_file2=cell(1,nfiles2);
for i=1:length(psi2)
    spe_file2{i}=[indir,'map',num2str(11062+i),'.spe;1'];
end

% Combine runs information
% --------------------------
nfiles=nfiles1+nfiles2;
psi=[psi1,psi2];
spe_file=[spe_file1,spe_file2];

gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);


% % =====================================================================================================================
% % Old script to create all the sqw files for the constant-ei iron experiment runs in Nov '06
% % =====================================================================================================================
% indir='D:\Fe\data_nov06\const_ei\';
% outdir='E:\fe\fe787\';
% par_file='D:\fe\9cards_4_4to1.par';
% 
% 
% % Set up information for Horace functions
% % -----------------------------------
% efix=787;
% emode=1;
% alatt=[2.87,2.87,2.87];
% angdeg=[90,90,90];
% u=[1,0,0];
% v=[0,1,0];
% omega=0;dpsi=0;gl=0;gs=0;
% 
% % psi=0(-0.5)-23 runs 11014->11060
% % -----------------------------------
% nfiles1=47;
% psi1=(pi/180)*linspace(0,-0.5*(nfiles1-1),nfiles1);
% spe_file1=cell(1,nfiles1);
% sqw_file1=cell(1,nfiles1);
% tmp_file1=cell(1,nfiles1);
% for i=1:length(psi1)
%     spe_file1{i}=[indir,'map',num2str(11013+i),'.spe;1'];
%     sqw_file1{i}=[outdir,'map',num2str(11013+i),'.sqw'];
%     tmp_file1{i}=[outdir,'map',num2str(11013+i),'.sqw_tmp'];
% end
% 
% % psi=-23.5(-0.5)-92.5 runs 11063->11201
% % ---------------------------------------
% nfiles2=139;
% psi2=(pi/180)*linspace(-23.5,-23.5-0.5*(nfiles2-1),nfiles2);
% spe_file2=cell(1,nfiles2);
% sqw_file2=cell(1,nfiles2);
% tmp_file2=cell(1,nfiles1);
% for i=1:length(psi2)
%     spe_file2{i}=[indir,'map',num2str(11062+i),'.spe;1'];
%     sqw_file2{i}=[outdir,'map',num2str(11062+i),'.sqw'];
%     tmp_file2{i}=[outdir,'map',num2str(11062+i),'.sqw_tmp'];
% end
% 
% % Combine runs information
% % --------------------------
% nfiles=nfiles1+nfiles2;
% psi=[psi1,psi2];
% spe_file=[spe_file1,spe_file2];
% sqw_file=[sqw_file1,sqw_file2];
% tmp_file=[tmp_file1,tmp_file2];
% 
% 
% % =====================================================================================================================
% % Generate the sqw files
% % =====================================================================================================================
% 
% for i=1:nfiles
%     write_spe_to_sqw (spe_file{i}, par_file, sqw_file{i}, efix, emode, alatt, angdeg, u, v, psi(i), omega, dpsi, gl, gs);
% end
% 
% 
% % =====================================================================================================================
% % Process sqw files into commensurately rebinned files
% % =====================================================================================================================
% 
% grid_size_in=50;
% grid_size = write_nsqw_to_nsqw (sqw_file, tmp_file, grid_size_in);
% 
% 
% % =====================================================================================================================
% % Create single sqw file combining all
% % =====================================================================================================================
% 
% write_nsqw_to_sqw (tmp_file, fullfile(outdir,'fe.sqw'));
% 

