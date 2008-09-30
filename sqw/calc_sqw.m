function [header,sqw_data]=calc_sqw (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det)
% Calculate sqw file header and data for a single spe file
%
%   >> [header,sqw_data]=calc_sqw (efix, emode, alatt, angdeg, u, v,...
%                                       psi, omega, dpsi, gl, gs, data, det)
% Input:
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
%   det         Data structure of par file (see get_par)
%
% Ouput:
%   header      Header information in data structure suitable for write_sqw_header
%   sqw_data    Data structure suitable for write_sqw_data

% T.G.Perring   26/06/2007

% Perform calculations
% -----------------------

% Get number of data elements
[ne,ndet]=size(data.S);

% Calculate projections
[u_to_rlu, ucoords] = calc_projections (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);

urange=[min(ucoords,[],2)';max(ucoords,[],2)'];
p=cell(1,4);
for id=1:4
    p{id}=[urange(1,id);urange(2,id)];
end


% Create header block and write:
% -------------------------------

header.filename = data.filename;
header.filepath = data.filepath;
header.efix = efix;
header.emode = emode;
header.alatt = alatt;
header.angdeg = angdeg;
header.cu = u;
header.cv = v;
header.psi = psi;
header.omega = omega;
header.dpsi = dpsi;
header.gl = gl;
header.gs = gs;
header.en = data.en;
header.uoffset = [0;0;0;0];
header.u_to_rlu = [[u_to_rlu;[0,0,0]],[0;0;0;1]];
header.ulen = [1,1,1,1];
header.ulabel = {'Q_\zeta','Q_\xi','Q_\eta','E'};

% Now package the data and write 
% -------------------------------
sqw_data.uoffset=[0;0;0;0];
sqw_data.u_to_rlu = [[u_to_rlu;[0,0,0]],[0;0;0;1]];
sqw_data.ulen = [1,1,1,1];
sqw_data.ulabel = {'Q_\zeta','Q_\xi','Q_\eta','E'};
sqw_data.iax=[];
sqw_data.iint=[];
sqw_data.pax=[1,2,3,4];
sqw_data.p=p;
sqw_data.dax=[1,2,3,4];
sqw_data.s=sum(data.S(:));
sqw_data.e=sum(data.ERR(:).^2);
sqw_data.npix=ne*ndet;
sqw_data.urange=urange;
sqw_data.pix=[ucoords;...
    ones(1,ne*ndet);...                                 % run index - all unity
    reshape(repmat(det.group,[ne,1]),[1,ne*ndet]);...   % detector index
    reshape(repmat([1:ne]',[1,ndet]),[1,ne*ndet]);...   % energy bin index
    data.S(:)';((data.ERR(:)).^2)'];
