function [nxspe_file_names,psi] = gen_bm_gen_sqw_data(dataSize,dataSet,detectorSize,efix,alatt,angdeg,u,v,omega,dpsi,gl,gs)
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
%                'large' or an input energy bin.
%   dataSet      the amount of nxspe files to generate. Char: 'small', 
%                'medium' or 'large' (12, 23 and 46 files respectively)
%                 or an integer amount of files.
%   detectorSize  number of detectors. 'small','medium', or 'large';
%                 35937,64000 and 125000 detectors respectively.
%   efix          Fixed energy (meV)                 [scalar or vector length nfile]
%   emode         Direct geometry=1, indirect geometry=2    [scalar]
%   alatt         Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg        Lattice angles (deg)               [row or column vector]
%   u             First vector (1x3) defining scattering plane (r.l.u.)
%   v             Second vector (1x3) defining scattering plane (r.l.u.)
%   omega         Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi          Correction to psi (deg)            [scalar or vector length nfile]
%   gl            Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs            Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
% Outputs:
%   nxspe_file_names    cell array of nxspe filenames
%   psi                 Angle of u w.r.t. ki (deg) [scalar or vector length nfile]

    pths = horace_paths;
    
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
    
    switch dataSize
        case 'small'
            en = 0:16:efix;
        case 'medium'
            en = 0:8:efix;
        case 'large'
            en = 0:4:efix;
        otherwise
            try
                en = dataSize;
            catch
                error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                    ,"dataSize is the size of the nxspe files used to generate an" + ...
                    "sqw object : must be small, medium, large (char type) or " + ...
                    "represnet the size of the ebins (an array of type: 0:X:Y)")
            end
    end
    
    switch detectorSize
        case 'small'
            q_range = [0 25 efix];
            num_detectors = 32768;
        case 'medium'
            q_range = [0 22 efix];
            num_detectors = 46656;
        case 'large'
            q_range = [0 19 efix];
            num_detectors = 74088;
        otherwise
            try
                q_range = detectorSize;
    %             num_detectors = 125000;
            catch
                error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                    ,"par_file must be a 3x1 or 3x3 array of q-ranges.")
            end
    end
    
    % Get oriented lattice object using alatt,angdeg etc to generate fake 
    % detector data
    lattice = convert_old_input_to_lat(alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
    par_file = build_det_from_q_range(q_range,efix,lattice);
    
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
