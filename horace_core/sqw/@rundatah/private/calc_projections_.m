function [u_to_rlu, pix_range, pix] = calc_projections_(obj, detdcn,qspec,proj_mode)
% project detector positions into Crystal Cartesian coordinate system
%
% Label pixels in an spe file with coords in the 4D space defined by crystal Cartesian coordinates and energy transfer.
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [u_to_rlu,pix_range, pix] = obj.calc_projections_(detdcn,qspec,proj_mode)
%
% Optional inputs:
% ------
%   qspec       4xn_detectors array of qx,qy,qz,eps
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                   [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
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
%   u_to_rlu    Matrix (3x3) of crystal Cartesian axes in reciprocal lattice units
%              i.e. u_to_rlu(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in
%              crystal Cartesian axes to r.l.u.: v_rlu = u_to_rlu * v_crystal_Cart
%              (Same as inv(B) in Busing and Levy convention)
%   pix_range  [2 x 4] array containing the full extent of the data in crystal Cartesian
%              coordinates and energy transfer; first row the minima, second row the
%              maxima.
%   pix        PixelData object
%              The order of the pixels is increasing energy dfor first detector, then
%              increasing energy for the second detector, ....

% Uses the following fiels of rundata opbject:
% efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det
% where  data  is the data structure of spe file (see get_spe)

% Original author: T.G.Perring
%


% Check input parameters
% -------------------------
[ne,ndet]=size(obj.S);
% Check length of detectors in spe file and par file are same
% if ~isfield(data,'qspec') &&  ndet~=length(det.phi)
%     mess1=['.spe file ' data.filename ' and .par file ' det.filename ' not compatible'];
%     mess2=['Number of detectors is different: ' num2str(ndet) ' and ' num2str(length(det.phi))];
%     error('%s\n%s',mess1,mess2)
% end
if ~exist('proj_mode','var')
    proj_mode = 2;
end
if ~exist('qspec','var')
    qspec = [];
end
if proj_mode<0 || proj_mode >2
    warning('HORACE:calc_projections',' proj_mode can be 0,1 or 2 and got %d. Assuming mode 2(all pixel information)',proj_mode);
    proj_mode = 2;
end


% Create matrix to convert from spectrometer axes to coordinates along crystal Cartesian projection axes
[spec_to_cc, u_to_rlu] = obj.lattice.calc_proj_matrix();

% Calculate Q in spectrometer coordinates for each pixel
[use_mex,nThreads]=config_store.instance().get_value('hor_config','use_mex','threads');
if use_mex
    if ~isempty(qspec) % why is this?
        use_mex = false;
    else
        try
            c=neutron_constants;
            k_to_e = c.c_k_to_emev;  % used by calc_projections_c;
            
            data = struct('S',obj.S,'ERR',obj.ERR,'en',obj.en,'run_id',obj.run_id);
            det  = obj.det_par;
            efix  = obj.efix;
            emode = obj.emode;
            %proj_mode = 2;
            %nThreads = 1;
            [pix_range,pix] =calc_projections_c(spec_to_cc, data, det, efix,k_to_e, emode, nThreads,proj_mode);
            if proj_mode==2
                pix = PixelData(pix);
            end
        catch  ERR % use Matlab routine
            warning('HORACE:using_mex','Problem with C-code: %s, using Matlab',ERR.message);
            use_mex=false;
        end
    end
end
if ~use_mex
    if isempty(qspec)
        qspec_provided = false;
        if isempty(detdcn)
            detdcn = calc_detdcn(obj.det_par);
        end
        [qspec,en]=obj.calc_qspec(detdcn);
        ucoords = [spec_to_cc*qspec;en];
    else
        ucoords = [spec_to_cc*qspec(1:3,:);qspec(4,:)];
        qspec_provided = true;
    end
    
    
    
    % Return without filling the pixel array if pix_range only is requested
    
    if proj_mode == 0
        pix_range=[min(ucoords,[],2)';max(ucoords,[],2)'];
        pix= [];
        return;
    end
    if proj_mode == 1
        pix_range=[min(ucoords,[],2)';max(ucoords,[],2)'];
        pix = ucoords;
        return
    end
    %Else: proj_mode==2
    
    % Fill in pixel data object
    if ~qspec_provided
        det = obj.det_par;
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
    run_id = ones(1,numel(detector_idx))*obj.run_id();
    pix = PixelData([ucoords;run_id;detector_idx;energy_idx;sig_var]);
    pix_range=pix.pix_range;
end

