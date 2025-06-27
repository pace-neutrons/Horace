function [pix_img_range, pix,obj] = calc_projections_(obj, detdcn,proj_mode)
% project detector positions into Crystal Cartesian coordinate system
%
% Label pixels in an spe file with coords in the 4D space defined by crystal Cartesian coordinates and energy transfer.
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [u_to_rlu,pix_range, pix] = obj.calc_projections_(detdcn,detdcn,proj_mode)
%
% Optional inputs:
% ------
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                   [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)] or
%                   empty array
%               This should be pre-calculated from the contents of det
%   proj_mode   The format of the pix output, the routine returns,
%               when proj_mode is as follows:
%     0         pix arry will be empty array
%     1         pix array will be [4 x nPix] array of transformed
%               uCoordinates, see below
%     2 or not present -- pix array will be [9 x nPix] array as described
%              below

%
% Output:
% -------
%   pix_img_range  [2 x 9] or [2 x 4] array containing the full
%              extent of the data, i.e pixels converted to the target 
%              coordinate system, namely:
%              First 4 columns contain pixel coordinates in crystal Cartesian
%              coordinate system namely 3 momentum coordinates and 4-th -
%              the energy transfer; first row the minima, second row the
%              maxima.
%              In modes 0 and 1 only 4 first columns contain usable
%              information so the data_range is restricted by 4 columns.
%   pix        PixelData object
%              The order of the pixels is increasing energy for first
%              detector, then increasing energy for the second detector, 
%              etc....

% Uses the following fields of rundata object:
% efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det
% where  data  is the data structure of spe file (see get_spe)
%
% Original author: T.G.Perring
%


% Check input parameters
% -------------------------
[ne,ndet]=size(obj.S);

if ~exist('proj_mode','var')
    proj_mode = 2;
end

%   qspec       4xn_detectors array of qx,qy,qz,eps
qspec = obj.qpsecs_cache; % if provided, used instead of detchn for calculations
qspec_provided = ~isempty(qspec);

if proj_mode<0 || proj_mode >2
    warning('HORACE:calc_projections', ...
        ' proj_mode can be 0,1 or 2 and got %d. Assuming mode 2(all pixel information)', ...
        proj_mode);
    proj_mode = 2;
end

% Create matrix to convert from spectrometer axes to coordinates along crystal Cartesian projection axes
spec_to_cc = obj.lattice.calc_proj_matrix(1);

% Calculate Q in spectrometer coordinates for each pixel
nThreads = config_store.instance().get_value('parallel_config', 'threads');
use_mex = config_store.instance().get_value('hor_config','use_mex');

if use_mex
    if qspec_provided % why is this? % See ticket #838 to address this.
        use_mex = false;
    else
        try
            c=neutron_constants;
            k_to_e = c.c_k_to_emev;  % used by calc_projections_c;

            data = struct('S',obj.S,'ERR',obj.ERR,'en',obj.en,'run_id',obj.run_id);
            % ensure the detpar struct is in row order for the
            % calc_projections_c call below
            det  = obj.get_det_par_rows();
            efix  = obj.efix;
            emode = obj.emode;
            %proj_mode = 2;
            %nThreads = 1;
            [pix_img_range,pix_arr] =calc_projections_c(spec_to_cc, data, det, efix,k_to_e, emode, nThreads,proj_mode);
            if proj_mode==2
                pix = PixelDataMemory();
                pix = pix.set_raw_data(pix_arr);
                pix = pix.set_data_range(pix_img_range);
            else
                pix = pix_arr;
                pix_img_range = pix_img_range(:,1:4);
            end
        catch  ERR % use Matlab routine
            warning('HORACE:using_mex', ...
                'Problem with C-code: %s, using Matlab',ERR.message);
            use_mex=false;
        end
    end
end

if ~use_mex
    if qspec_provided %   qspec 4xn_detectors array of qx,qy,qz,eps
        ucoords = [spec_to_cc*qspec(1:3,:);qspec(4,:)];
    else
        qspec_provided = false;
        if isempty(detdcn)
            det = obj.det_par;
            detdcn = calc_detdcn(det.phi,det.azim);
        end
        [qspec,en]=obj.calc_qspec(detdcn);
        ucoords = [spec_to_cc*qspec;en];

    end

    % Return without filling the pixel array if pix_range only is requested
    switch proj_mode
        case 0
            pix_img_range = [min(ucoords,[],2)';max(ucoords,[],2)'];
            pix = [];
        case 1
            pix_img_range = [min(ucoords,[],2)';max(ucoords,[],2)'];
            pix = ucoords;
        case 2
            % Fill in pixel data object
            if ~qspec_provided
                % ensure the detpar structure is in row order. This is probably unnecessary 
                % (the test_sqw suite works with and without) but change made for consistency
                % with the use_mex section above
                det = obj.get_det_par_rows();
                if isfield(det,'group')
                    detector_idx=reshape(repmat(det.group,[ne,1]),[1,ne*ndet]); % detector index
                else
                    group = 1:ndet;
                    detector_idx=reshape(repmat(group,[ne,1]),[1,ne*ndet]); % detector index
                end
                energy_idx=reshape(repmat((1:ne)',[1,ndet]),[1,ne*ndet]); % energy bin index
            else
                detector_idx = ones(1,ne*ndet);
                energy_idx = ones(1,ne*ndet);
            end
            sig_var =[obj.S(:)';((obj.ERR(:)).^2)'];
            run_id = ones(1,numel(detector_idx))*obj.run_id;
            pix = PixelDataBase.create([ucoords;run_id;detector_idx;energy_idx;sig_var]);
            pix_img_range=pix.data_range;
    end
end
