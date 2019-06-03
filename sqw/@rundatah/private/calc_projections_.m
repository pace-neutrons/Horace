function [u_to_rlu, urange, pix] = calc_projections_(obj, detdcn,qspec,proj_mode)
% Label pixels in an spe file with coords in the 4D space defined by crystal Cartesian coordinates and energy transfer.
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [u_to_rlu, ucoords] = obj.calc_projections_(detdcn,qspec,proj_mode)
%
% Optional inputs:
% ------
%   qspec       4xn_detectors array of qx,qy,qz,eps
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                   [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%               This should be precalculated from the contents of det
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
%   urange      [2 x 4] array containing the full extent of the data in crystal Cartesian
%              coordinates and energy transfer; first row the minima, second row the
%              maxima.
%   pix         [9 x npix] array of pixel information:
%                   pix(1:4,:)  coordinates in crystal Cartesian coordinates and energy
%                   pix(5,:)    run index: alway unity from this routine
%                   pix(6,:)    detecetor index
%                   pix(7,:)    energy bin index
%                   pix(8,:)    signal
%                   pix(9,:)    error squared
%              The order of the pixels is increasing energy dfor first detector, then
%              increasing energy for the second detector, ....

% Uses the following fiels of rundata opbject:
% efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det
% where  data  is the data structure of spe file (see get_spe)

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)


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


% Create matrix to convert from spectrometer axes to coordinates along projection axes
[spec_to_u, u_to_rlu] = obj.lattice.calc_proj_matrix();

% Calculate Q in spectrometer coordinates for each pixel
[use_mex,nThreads]=config_store.instance().get_value('hor_config','use_mex','threads');
if use_mex
    if ~isempty(qspec) % why is this?
        use_mex = false;
    else
        try
            c=neutron_constants;
            k_to_e = c.c_k_to_emev;  % used by calc_projections_c;
            
            data = struct('S',obj.S,'ERR',obj.ERR,'en',obj.en);
            det  = obj.det_par;
            efix  = obj.efix;
            emode = obj.emode;
            %nThreads = 8;
            [urange,pix] =calc_projections_c(spec_to_u, data, det, efix, k_to_e, emode, nThreads,proj_mode);
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
        ucoords = [spec_to_u*qspec;en];
    else
        ucoords = [spec_to_u*qspec(1:3,:);qspec(4,:)];
        qspec_provided = true;        
    end
    
    urange=[min(ucoords,[],2)';max(ucoords,[],2)'];
    
    % Return without filling the pixel array if urange only is requested
    if nargout==2
        return;
    end
    if proj_mode == 0
        pix =[];
        return;
    end
    if proj_mode == 1
        pix =ucoords;
        return;
    end
    
    % Fill pixel array
    pix=ones(9,ne*ndet);
    pix(1:4,:)=ucoords;
    clear ucoords;  % delete big array before creating another big array
    if ~qspec_provided
        det = obj.det_par;
        if isfield(det,'group')
            pix(6,:)=reshape(repmat(det.group,[ne,1]),[1,ne*ndet]); % detector index
        else
            group = 1:ndet;
            pix(6,:)=reshape(repmat(group,[ne,1]),[1,ne*ndet]); % detector index
        end
        pix(7,:)=reshape(repmat((1:ne)',[1,ndet]),[1,ne*ndet]); % energy bin index
    else
        pix(6:7,:)=1;
    end
    pix(8,:)=obj.S(:)';
    pix(9,:)=((obj.ERR(:)).^2)';
    
end
