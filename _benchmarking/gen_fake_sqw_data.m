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
% nData     an integer between [6-10]

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
        case 6 % Generates sqw obj with 10^6
            e_bin_boundaries=0:80:efix;
            n_a = floor(sqrt(1e5/numel(e_bin_boundaries)));
            psi=0:4:90;
        case 7 % Generates sqw obj with 10^7
            e_bin_boundaries=0:32:efix;
            n_a = floor(sqrt(1e6/numel(e_bin_boundaries)));
            psi=0:3:90;
        case 8 % Generates sqw obj with 10^8
            e_bin_boundaries=0:32:efix;
            n_a = floor(sqrt(1e7/numel(e_bin_boundaries)));
            psi=0:2:90;
        case 9 % Generates sqw obj with 10^9
            e_bin_boundaries=0:24:efix;
            n_a = floor(sqrt(4e7/numel(e_bin_boundaries)));
            psi=0:2:90;
        case 10 % Generates sqw obj with 10^10
            e_bin_boundaries=0:12:efix;
            n_a = floor(sqrt(1e8/numel(e_bin_boundaries)));
            psi=0:2:90;
        otherwise
            error("HORACE:gen_bm_data:invalid_argument",...
                "When using a integer, nData must be between 6 and 10.")
    end

    % Alternative using fixed detector angles
    % Angular limits {{lower, upper, n}, {left, right, n}}:
    ang_lims = {{5, 60, n_a}, {-170, 170, n_a}};  % For MAPS
    %ang_lims = {{5, 130, n_a}, {-170, 170, n_a}};  % For MERLIN / LET
    theta_angs = linspace(ang_lims{1}{:});
    phi_angs = linspace(ang_lims{2}{:});
    [theta2d, phi2d] = ndgrid(theta_angs, phi_angs);
    theta2d = theta2d(:);
    phi2d = phi2d(:);
    r = ones(size(theta2d)) .* 6;   % for MAPS, r=6; for MERLIN, r = 2.5; for LET, r = 4;
    detwidth = ones(size(theta2d)) .* 0.0254;   % in metres (1" diameter tubes)
    detheight = ones(size(theta2d)) .* 0.017;   % in metres (1m long tubes split into 256 "pixels")
    par_file = get_hor_format([r theta2d phi2d detwidth detheight [1:numel(theta2d)]']');
    
    disp("--------------------------------------")
    disp("Generating sqw object with 10^" + nData + " pixels:")
    dummy_sqw(e_bin_boundaries,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
    output_sqw = sqw_file;
    disp("Sqw object generated")
    disp("--------------------")
    
end