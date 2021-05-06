function [ok, mess, sample, s_mat, spec_to_rlu, alatt, angdeg] =...
    sample_coords_to_spec_to_rlu (header)
% Get the matrix to convert a coordinate in the sample coordinate frame to laboratory frame
%
%   >> [ok, mess, sample, s_mat, spec_to_rlu, alatt, angdeg] =...
%                                     sample_coords_to_spec_to_rlu (header)
%
% Input:
% ------
%   header      Header field in sqw object
%
% Output:
% -------
%   ok          Status: = true if all OK, =false otherwise
%   mess        Error message: empty if OK, filled otherwise
%   sample      Sample object (must be the same for every contributing run)
%   s_mat       Matrix to convert coords in sample frame to spectrometer frame.
%               Size is [3,3,nrun], where nrun is the number of runs that contribute to the sqw object.
%   spec_to_rlu Matrix to convert momentum in spectrometer coordinates to components in r.l.u.:
%                   v_rlu = spec_to_rlu * v_spec
%               Size is [3,3,nrun], where nrun is the number of runs that contribute to the sqw object.
%   alatt       Lattice parameters (row vector length 3)
%   angdeg      Lattice angles in degrees (row vector length 3)

% Check sample descrption the same for all spe files in the sqw object
if ~iscell(header)
    nrun=1;
    sample=header.sample;
    alatt=header.alatt;
    angdeg=header.angdeg;
else
    nrun=numel(header);
    sample=header{1}.sample;
    alatt=header{1}.alatt;
    angdeg=header{2}.angdeg;
    for i=2:numel(header)
        if ~isequal(sample,header{i}.sample)
            ok=false;
            mess='Sample description must be identical for all contributing spe files';
            return
        end
        if ~all(alatt==header{i}.alatt) && ~all(angdeg==header{i}.angdeg)
            ok=false;
            mess='Lattice parameters must be identical for all contributing spe files';
            return
        end
    end
end

% Fill s_mat
xgeom=sample.xgeom;
ygeom=sample.ygeom;
s_mat=zeros(3,3,nrun);
spec_to_rlu=zeros(3,3,nrun);
for i=1:nrun
    if nrun~=1
        h=header{i};
    else
        h=header;
    end
    % Matrix to convert from laboratory frame to crystal Cartesian coordinates, and to rlu
    [spec_to_u, ~, spec_to_rlu(:,:,i)]=calc_proj_matrix (h.alatt, h.angdeg, h.cu, h.cv, h.psi, h.omega, h.dpsi, h.gl, h.gs); % Vcryst = spec_to_u * Vspec
    % Matrix to convert from crystal Cartesian coordinates to frame defined by sample geometry (x,y axes in r.l.u.)
    b=bmatrix(h.alatt, h.angdeg);
    [~,~,umat]=ubmatrix(xgeom, ygeom, b);   % Vsamp(i) = umat * Vcryst
    % Matrix to convert from sample coordinate frame to laboratory frame
    s_mat(:,:,i)=spec_to_u\umat';  % use fact that inverse of umat is the same as transpose of umat
end

ok=true;
mess='';
