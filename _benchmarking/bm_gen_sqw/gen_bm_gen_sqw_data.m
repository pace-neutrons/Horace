function [nxspe_file_names,psi] = gen_bm_gen_sqw_data(dataSize,dataSet,detectorSize,efix)
%GEN_GEN_SQW_DATA This function generates the required data to run gen_sqw
%benchmarks
%   To run the benchmarks, par and nxspe data need to be generated in
%   order to supply the required sample, instrument and experiment
%   information to gen_sqw.
%   This function sets the values of efix, psi and the energy boundaries.
%   These variables will set the size of:
%   - The size of the nxspe files. Set by en (energy boundaries)
%   - The size of the dataSets used (12 ,23 and 46 nxspe files generated
%     for small, medium and large respectively). Set by psi.
%   - The fake detector file. Set by givng a q-range (par_file) and number
%     of detectors (detectorNum).
%   The necessary detector info and nxspe files will then be generated 
%
% Inputs:
%   dataSize     determined by the input Energy bin boundaries (must be 
%                monotonically increasing and equally spaced) or cell array
%                of arrays of energy bin boundaries, one array per spe
%                file. Energy bins are either: char: 'small','medium' and
%                'large' or an integer to split 787 into seperate bins.
%   dataSet      the amount of nxspe files to generate. Char: 'small', 
%                'medium' or 'large' (12, 23 and 46 files respectively)
%                 or an integer amount of files (the integer here will 
%                 divide 90 to give the final amountof nxspe files i.e.10 
%                 will generate 9 files: 90/10).
%   detectorSize  number of detectors. 'small','medium', or 'large'.
%                 Corresponding to MAPS, MERLIN and LET.
%   efix          Fixed energy (meV)                 [scalar or vector length nfile]
%   emode         Direct geometry=1, indirect geometry=2    [scalar]
%
% Outputs:
%   nxspe_file_names    cell array of nxspe filenames
%   psi                 Angle of u w.r.t. ki (deg) [scalar or vector length nfile]

    pths = horace_paths;

    switch dataSize
        case 'small'
            en = 0:16:efix;
        case 'medium'
            en = 0:8:efix;
        case 'large'
            en = 0:4:efix;
        otherwise
            try
                en = 0:dataSize:efix;
            catch
                error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                    ,"dataSize is the size of the nxspe files used to generate an" + ...
                    "sqw object : must be small, medium, large (char type) or " + ...
                    "represent the size of the ebins (an array of type: 0:X:Y)")
            end
    end

    switch dataSet
        case 'small'
            psi = 0:8:90;
        case 'medium'
            psi = 0:4:90;
        case 'large'
            psi = 0:2:90;
        otherwise
            try
                psi = 0:90/dataSet:90;
            catch
                error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                    ,"dataSet is the number of nxspe files used to generate an" + ...
                    "sqw object : must be small, medium, large (char type) or " + ...
                    "and array (0:X:Y)")
            end
    end
    
    folder_pth = fullfile(pths.bm,'bm_gen_sqw');
    spe_file_names = cell(1,numel(psi));
    nxspe_file_names = cell(1,numel(psi));
    
    switch detectorSize
        case 'small'
            num_detectors = 36864; % ~Num of detector pixels for MAPS
            n_a = floor(sqrt(num_detectors));
            ang_lims = {{5, 60, n_a}, {-170, 170, n_a}};  % For MAPS
            theta_angs = linspace(ang_lims{1}{:});
            phi_angs = linspace(ang_lims{2}{:});
            [theta2d, phi2d] = ndgrid(theta_angs, phi_angs);
            theta2d = theta2d(:);
            phi2d = phi2d(:);
            r = ones(size(theta2d)) .* 6;   % for MAPS, r=6; 
        case 'medium'
            num_detectors = 69169; % ~Num of detector pixels for MERLIN
            n_a = floor(sqrt(num_detectors));
            ang_lims = {{5, 130, n_a}, {-170, 170, n_a}};  % For MERLIN
            theta_angs = linspace(ang_lims{1}{:});
            phi_angs = linspace(ang_lims{2}{:});
            [theta2d, phi2d] = ndgrid(theta_angs, phi_angs);
            theta2d = theta2d(:);
            phi2d = phi2d(:);
            r = ones(size(theta2d)) .* 2.5;   % for MERLIN, r = 2.5;
        case 'large'
            num_detectors = 97969; % ~Num of detector pixels for LET
            n_a = floor(sqrt(num_detectors));
            ang_lims = {{5, 130, n_a}, {-170, 170, n_a}};  % LET
            theta_angs = linspace(ang_lims{1}{:});
            phi_angs = linspace(ang_lims{2}{:});
            [theta2d, phi2d] = ndgrid(theta_angs, phi_angs);
            theta2d = theta2d(:);
            phi2d = phi2d(:);
            r = ones(size(theta2d)) .* 4;   % for LET, r = 4;
        otherwise
            try
                num_detectors = detectorSize; % Num of detector pixels
                n_a = floor(sqrt(num_detectors));
                ang_lims = {{5, 130, n_a}, {-170, 170, n_a}};
                theta_angs = linspace(ang_lims{1}{:});
                phi_angs = linspace(ang_lims{2}{:});
                [theta2d, phi2d] = ndgrid(theta_angs, phi_angs);
                theta2d = theta2d(:);
                phi2d = phi2d(:);
                r = ones(size(theta2d)) .* 2;
            catch
                error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                    ,"par_file must be a small, medium, large (char type) or " + ...
                    "or an array with [numDetectorPixels, r]")
            end
    end

    detwidth = ones(size(theta2d)) .* 0.0254;   % in metres (1" diameter tubes)
    detheight = ones(size(theta2d)) .* 0.017;   % in metres (1m long tubes split into 256 "pixels")
    par_file = get_hor_format([r theta2d phi2d detwidth detheight [1:numel(theta2d)]']');

    for i=1:numel(psi)
        spe_file_names{i}=fullfile(['bm_gen_sqw',num2str(i),'.spe']);
        nxspe_file_names{i}=fullfile(['bm_gen_sqw',num2str(i),'.nxspe']);
        if ~is_file(spe_file_names{i})
            spe_data = dummy_spe(num_detectors,en,spe_file_names{i},folder_pth);
            % Convert spe files to nxspe files
            gen_nxspe(spe_data.S,spe_data.ERR,spe_data.en,par_file,...
                nxspe_file_names{i},efix)
            % Get rid of spe files once nxspe files have been generated
            delete(spe_file_names{i})
        end
    end

end

