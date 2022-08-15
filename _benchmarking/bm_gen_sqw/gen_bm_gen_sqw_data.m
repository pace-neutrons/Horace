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
%   The necessary detector info and nxspe files will be generated and
%   passed on to benchmark_gen_sqw()

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
            psi = dataSet;
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
        par_file = [0 24 efix];
        num_detectors = 35937;
    case 'medium'
        par_file = [0 20 efix];
        num_detectors = 64000;
    case 'large'
        par_file = [0 16 efix];
        num_detectors = 125000;
    otherwise
        try
            par_file = detectorSize;
%             num_detectors = 125000;
        catch
            error("HORACE:gen_bm_gen_sqw_data:invalid_argument"...
                ,"par_file must be a 3x1 or 3x3 array of q-ranges.")
        end
end

% Get oriented lattice object using alatt,angdeg etc to generate fake 
% detector data
lattice = convert_old_input_to_lat(alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
par_file = build_det_from_q_range(par_file,efix,lattice);

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
