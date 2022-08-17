function output_sqw = gen_fake_sqw_data(nData)
%   This function will generate an sqw object for benchmarking using dummy_sqw
%   Using the input parameter nData, dummy_sqw will generate an sqw object
%   with the requested amount of pixel data. nData must be an integer
%   ranging from 5 to 9. Depending on nData, an sqw object with
%   10^nData pixels will be generated. Parameters fed into dummy_sqw, such
%   as alatt, u, v are currently set to generate an iron sqw object.
%   These parameters can be changed by the user.
% 
% Inputs:
% nData     an integer between [5-9]


%% Set parameters for generating an sqw object
    pths = horace_paths;
    common_data = pths.bm_common;
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
            e_bin_boundaries=0:80:efix;
%             q_range = [0 80 efix];
            psi=0:4:90;
        case 6 % Generates sqw obj with 10^6 pixels
            e_bin_boundaries=0:32:efix;
%             q_range = [0 32 efix];
            psi=0:4:90;
        case 7 % Generates sqw obj with 10^7 pixels
            e_bin_boundaries=0:32:efix;
%             q_range = [0 32 efix];
            psi=0:2:90;
        case 8 % Generates sqw obj with 10^8 pixels
            e_bin_boundaries=0:16:efix;
%             q_range = [0 16 efix];
            psi=0:2:90;
        case 9 % Generates sqw obj with 10^9 pixels
            e_bin_boundaries=0:12:efix;
%             q_range = [0 12 efix];
            psi=0:2:90;
        otherwise
            error("HORACE:gen_bm_data:invalid_argument",...
                "When using a integer, nData must be between 5 and 9.")
    end

% Get oriented lattice object using alatt,angdeg etc to generate fake 
% detector data
%     lattice = convert_old_input_to_lat(alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
%     par_file = build_det_from_q_range(q_range,efix,lattice);
    par_file = [common_data,filesep,'4to1_124.par'];
    
    disp("--------------------------------------")
    disp("Generating sqw object with 10^" + nData + " pixels:")
    dummy_sqw(e_bin_boundaries,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
    output_sqw = sqw_file;
    sqw_obj = sqw(output_sqw);
    disp(sqw_obj.npixels)
    disp("Sqw object generated")
    disp("--------------------")
end