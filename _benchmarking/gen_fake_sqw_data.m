function dataSource = gen_fake_sqw_data(nData)
% This function will generate an sqw object for benchmarking using fake_sqw
%   Using the input parameter nData, fake_sqw will generate an sqw object
%   with the requested amount of pixel data. nData must be an integer
%   ranging from 5 to 8/9/10?????. Depending on nData, an sqw object with
%   10^nData pixels will be generated. Parameters fed into fake_sqw, such
%   as alatt, u, v are currently set to generate an iron sqw object. 
%   These parameters can be canged by the user 

horace_path = horace_root();
bm_path = fullfile(horace_path,'_benchmarking');
common_data=fullfile(bm_path,'common_data');
%% Set parameters for generating an sqw object
efix=787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;
% Set e_bin_boundaries and psi to get npix in the right order of magnitude
switch nData
    case 5
        e_bin_boundaries=0:16:efix;
        psi=0:4:90;
    case 6
        e_bin_boundaries=0:4:efix;
        psi=0:4:90;
    case 7
        e_bin_boundaries=0:efix;
        psi=0:2:90;
    case 8
        e_bin_boundaries=0:efix;
        psi=0:0.1:90;
        
    otherwise
        error("HORACE:gen_bm_data:invalid_argument",...
            "When using a integer, nData must be between 5 and 8.")
end

par_file=fullfile(common_data,'4to1_124.par');
sqw_file=[common_data,filesep,'NumData',num2str(nData),'.sqw']; % output sqw file

disp("------------------------------------------------------------------------")
disp("Generating the sqw object of specified data size.")
disp("------------------------------------------------------------------------")
%         data = fake_sqw(e_bin_boundaries,par_file,'',efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
fake_sqw(e_bin_boundaries,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
dataSource = sqw_file;
disp("--------------------------------------------------------------------------------------------")
disp("Sqw object has been generated, now proceeding to benchmark cut_sqw with specified parameters")
disp("--------------------------------------------------------------------------------------------")
end

