function [u_to_rlu, ucoords] =  calc_projections (this,Detectors,Crystal,efix,en_transfers,u, v)
% Label pixels in an spe file with coords in the 4D space defined by crystal Cartesian coordinates
% and energy transfer. 
%
%   >> [u_to_rlu, ucoords] = ...
%    calc_projections (this, Detectors,Crystal,efix, en_transfers, u, v)
%
% Input:
%   emode       Direct geometry=1,
%  Crystal       class defining a crystalline lattice in (direct and
%                    reciprocal)
% Detectors    class describing the detector's locations
%  
%   efix            Fixed energy (meV)
%  en_transfers energy transfers defining the energy dimension
%   u           First vector (1x3) defining scattering plane (r.l.u.)
%   v           Second vector (1x3) defining scattering plane (r.l.u.)
%
%
% Output:
%   u_to_rlu    Matrix (3x3) of projection axes in reciprocal lattice units
%              i.e. u(:,1) first vector - u(1:3,1) r.l.u. etc.
%              This matrix can be used to convert components of a vector in the
%              projection axes to r.l.u.: v_rlu = u * v_proj
%   ucoords     [4 x npix] array of coordinates of pixels in crystal Cartesian
%              coordinates and energy transfer

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
%
% Check input parameters
% -------------------------
ndet   = getNDetectors(Detectors);
nen    = numel(en_transfers);
data.S= ones(nen,ndet);

if size(en_transfers,2)>1
    data.en=en_transfers';
else
    data.en=en_transfers;
end
if  size(data.en,1)~=nen
    error('GONIOMETER:cald_projections',' enerty transfer array have to be 1D vector');
end

% Create matrix to convert from spectrometer axes to coords along projection axes
[spec_to_proj, u_to_rlu] = calc_proj_matrix (this,Crystal,u, v);

% TGP June 2013: update to source of constants; replace
%   c=get_neutron_constants;
%   k_to_e = c.k_to_e; % picked up by calc_proj_c;
% with
c=neutron_constants;
k_to_e = c.c_k_to_emev;

% Convert to projection axes 

% Calculate Q in spectrometer coordinates for each pixel 
use_mex=get(hor_config,'use_mex');
if use_mex
    try     %
        nThreads=get(hor_config,'threads'); % picked up by calc_proj_c;
         ucoords =calc_projections_c(spec_to_proj,data, getDetStruct(Detectors),efix, k_to_e,1,nThreads);
    catch   Err%using matlab routine
        warning('HORACE:using_mex','Problem with C-code: %s, using Matlab',Err.message);   
        use_mex=false;
    end    
end
if ~use_mex
    qspec = calc_qspec_emode1(Detectors,efix,en_transfers,k_to_e);      
%    ucoords = calc_proj_matlab (spec_to_proj, qspec);
    ucoords = spec_to_proj*qspec(1:3,:);
    ucoords = [ucoords;qspec(4,:)];   

end

