function [u_to_rlu, urange, pix] = ...
    calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det, detdcn)
% Label pixels in an spe file with coords in the 4D space defined by crystal Cartesian coordinates and energy transfer.
% Allows for correction scattering plane (omega, dpsi, gl, gs) - see Tobyfit for conventions
%
%   >> [u_to_rlu, ucoords] = ...
%    calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
%
% Input:
% ------
%   efix        Fixed energy (meV)
%   emode       Direct geometry=1, indirect geometry=2
%   alatt       Lattice parameters (Ang^-1)
%   angdeg      Lattice angles (deg)
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%   psi         Angle of u w.r.t. ki (rad)
%   omega       Angle of axis of small goniometer arc w.r.t. notional u
%   dpsi        Correction to psi (rad)
%   gl          Large goniometer arc angle (rad)
%   gs          Small goniometer arc angle (rad)
%   data        Data structure of spe file (see get_spe)
%            or The same, but with in addition a field qspec, a 4xn array of qx,qy,qz,eps
%   det         Data structure of par file (see get_par)
%            or If data has field qspec, det is ignored
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%                   [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%               This should be precalculated from the contents of det
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

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Check input parameters
% -------------------------
[ne,ndet]=size(data.S);
% Check length of detectors in spe file and par file are same
if ~isfield(data,'qspec') && ndet~=length(det.phi)
    mess1=['.spe file ' data.filename ' and .par file ' det.filename ' not compatible'];
    mess2=['Number of detectors is different: ' num2str(ndet) ' and ' num2str(length(det.phi))];
    error('%s\n%s',mess1,mess2)
end

% Check incident energy consistent with energy bins
% (if data contains the field qspec, then en is 2x1 array with min and max energy transfer)
if emode==1 && data.en(end)>=efix
    error(['Incident energy ' num2str(efix) ' and energy bins incompatible'])
elseif emode==2 && data.en(1)<=-efix
    error(['Final energy ' num2str(efix) ' and energy bins incompatible'])
elseif emode==0 && exp(data.en(1))<0 && ~isfield(data,'qspec')    % if qspec is not a field, then en contains log of wavelength
    error('Elastic scattering mode and wavelength bins incompatible')
end

% Create matrix to convert from spectrometer axes to coords along projection axes
[spec_to_u, u_to_rlu] = calc_proj_matrix (alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

c=neutron_constants;
k_to_e = c.c_k_to_emev;  % used by calc_projections_c;

% Calculate Q in spectrometer coordinates for each pixel
use_mex=get(hor_config,'use_mex') && emode==1 && ~isfield(data,'qspec');  % *** as of 6 Nov 2011 the c++ routine still only works for direct geometry
if use_mex
    if isfield(data,'qspec')
        use_mex = false;
    else
        try
            nThreads=get(hor_config,'threads');
            [urange,pix] =calc_projections_c(spec_to_u, data, det, efix, k_to_e, emode, nThreads);
        catch   % use matlab routine
            warning('HORACE:using_mex','Problem with C-code: %s, using Matlab',lasterr());
            use_mex=false;
        end
    end
end
if ~use_mex
    if ~isfield(data,'qspec')
        [qspec,en]=calc_qspec(efix, k_to_e, emode, data, detdcn);
        ucoords = [spec_to_u*qspec;en];
    else
        qspec=data.qspec;
        ucoords = [spec_to_u*qspec(1:3,:);qspec(4,:)];
    end
    
    urange=[min(ucoords,[],2)';max(ucoords,[],2)'];
    
    % Return without filling the pixel array if urange only is requested
    if nargout==2
        return;
    end
    
    % Fill pixel array
    pix=ones(9,ne*ndet);
    pix(1:4,:)=ucoords;
    clear ucoords;  % delete big array before creating another big array
    if ~isfield(data,'qspec')
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
    pix(8,:)=data.S(:)';
    pix(9,:)=((data.ERR(:)).^2)';
  
end
