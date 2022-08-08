function output_sqw = gen_fake_sqw_data(nData)
% This function will generate an sqw object for benchmarking using dummy_sqw
%   Using the input parameter nData, dummy_sqw will generate an sqw object
%   with the requested amount of pixel data. nData must be an integer
%   ranging from 5 to 9. Depending on nData, an sqw object with
%   10^nData pixels will be generated. Parameters fed into dummy_sqw, such
%   as alatt, u, v are currently set to generate an iron sqw object.
%   These parameters can be changed by the user


%% Set parameters for generating an sqw object
% main_sqw=fullfile(common_data,'NumData9.sqw');
pths = horace_paths;
common_data = pths.bm_common;
% proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
sqw_file=[common_data,filesep,'NumData',num2str(nData),'.sqw']; % output sqw file
efix=787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

%% Set parameters for generating an sqw object

% Set e_bin_boundaries and psi to get npix in the right order of magnitude
switch nData
    case 5 % Generates sqw obj with 10^5 pixels
        e_bin_boundaries=0:128:efix;
        psi=0:4:90;
%             p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];
%             p4_bin=[0,128,787];
%         if isfile(main_sqw)
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^5 pixels:")
%             sqw5=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             disp(sqw5.npixels)
%             save(sqw5,sqw_file)
%             disp("Sqw object generated")
%             disp("--------------------")
%         else
%             gen_main_sqw(common_data);
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^5 pixels:")
%             sqw5=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             save(sqw5,sqw_file)
%             disp("Sqw object generated")
%             disp("--------------------")
%         end
    case 6 % Generates sqw obj with 10^6 pixels
        e_bin_boundaries=0:80:efix;
        psi=0:4:90;
%         p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];
%         p4_bin=[0,80,787];
%         if isfile(main_sqw)
%             disp("main_sqw exisits: " + main_sqw)
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^6 pixels:")
%             sqw6=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             disp(sqw6.npixels)
%             save(sqw6,sqw_file);
%             disp("Sqw object generated")
%             disp("--------------------")
%         else
%             disp("main_sqw doesn't exisits")
%             gen_main_sqw(common_data);
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^6 pixels:")
%             sqw6=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             disp(sqw6.npixels)
%             save(sqw6,sqw_file)
%             disp("Sqw object generated")
%             disp("--------------------")
%         end
    case 7 % Generates sqw obj with 10^7 pixels
        e_bin_boundaries=0:16:efix;
        psi=0:4:90;
%         p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];
%         p4_bin=[0,16,787];
%         if isfile(main_sqw)
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^7 pixels:")
%             sqw7=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             disp(sqw7.npixels)
%             save(sqw7,sqw_file)
%             disp("Sqw object generated")
%             disp("--------------------")
%         else
%             gen_main_sqw(common_data);
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^7 pixels:")
%             sqw7=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             disp(sqw7.npixels)
%             save(sqw7,sqw_file)
%             disp("Sqw object generated")
%             disp("--------------------")
%         end
    case 8 % Generates sqw obj with 10^8 pixels
        e_bin_boundaries=0:4:efix;
        psi=0:4:90;
%         p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];
%         p4_bin=[0,4,787];
%         if isfile(main_sqw)
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^8 pixels:")
%             sqw8=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             disp(sqw8.npixels)
%             save(sqw8,sqw_file)
%             disp("Sqw object generated")
%             disp("--------------------")
%         else
%             gen_main_sqw(common_data);
%             disp("--------------------------------------")
%             disp("Generating sqw object with 10^8 pixels:")
%             sqw8=cut_sqw(main_sqw,proj,p1_bin,p2_bin,p3_bin,p4_bin);
%             disp(sqw8.npixels)
%             save(sqw8,sqw_file)
%             disp("Sqw object generated")
%             disp("--------------------")
%         end
    case 9 % Generates sqw obj with 10^9 pixels
        e_bin_boundaries=0:1:efix;
        psi=0:2:90;
%         if isfile(main_sqw)
%             disp("10^9 pixel sqw object has already been generated")
%         else
%             gen_main_sqw(common_data)
%         end
    otherwise
        error("HORACE:gen_bm_data:invalid_argument",...
            "When using a integer, nData must be between 5 and 9.")
end

par_file=fullfile(common_data,'4to1_124.par');
disp("--------------------------------------")
disp("Generating sqw object with 10^" + nData + " pixels:")

dummy_sqw(e_bin_boundaries,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);

output_sqw = sqw_file;
disp("Sqw object generated")
disp("--------------------")

end

% function gen_main_sqw(filepath)
%
%     sqw_file=[filepath,filesep,'NumData9.sqw']; % output sqw file
%     efix=787;
%     emode=1;
%     alatt=[2.87,2.87,2.87];
%     angdeg=[90,90,90];
%     u=[1,0,0];
%     v=[0,1,0];
%     omega=0;dpsi=0;gl=0;gs=0;
%     e_bin_boundaries=0:1:efix;
%     psi=0:2:90;
%     par_file=fullfile(filepath,'4to1_124.par');
%     disp("--------------------------------------")
%     disp("Generating sqw object with 10^9 pixels:")
%
%     dummy_sqw(e_bin_boundaries,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
%
%     disp("Sqw object generated")
%     disp("--------------------")
% end