function [ok, mess, sample, s_mat, spec_to_rlu] = sample_coords_to_spec_to_rlu (header)
% Get the matrix to convert a coordinate in the sample coordinate frame to laboratory frame
%
%   >> [sample, s_mat] = sample_coords_to_spec_to_rlu (header)
%
% Input:
% ------
%   header      Header field in sqw object
%
% Output:
% -------
%   ok          Status: = true if all OK, =false otherwise
%   mess        Error message: empty if OK, filled otherwise
%   sample      Sample structure or object (must be the same for every contributing run)
%   s_mat       Matrix to convert coords in sample frame to spectrometer frame.
%               Size is [3,3,nrun], where nrun is the number of runs that contribute to the sqw object.
%   spec_to_rlu Matrix to convert momentum in spectrometer coordinates to components in r.l.u.:
%                   v_rlu = spec_to_rlu * v_spec
%               Size is [3,3,nrun], where nrun is the number of runs that contribute to the sqw object.


% Check sample descrption the same for all spe files in the sqw object
if ~iscell(header)
    nrun=1;
    sample=header.sample;
else
    nrun=numel(header);
    sample=header{1}.sample;
    for i=2:numel(header)
        if ~isequal(sample,header{i}.sample)
            ok=false;
            mess='Sample description must be identical for all contributing spe files';
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
    [spec_to_u, u_to_rlu, spec_to_rlu(:,:,i)]=calc_proj_matrix (h.alatt, h.angdeg, h.cu, h.cv, h.psi, h.omega, h.dpsi, h.gl, h.gs); % Vcryst = spec_to_u * Vspec
    % Matrix to convert from crystal Cartesian coordinates to frame defined by sample geometry (x,y axes in r.l.u.)
    b=bmatrix(h.alatt, h.angdeg);
    [ub,mess,umat]=ubmatrix(xgeom, ygeom, b);   % Vsamp(i) = umat * Vcryst
    % matrix to convert from sample coordinate frame to laboratory frame
    s_mat(:,:,i)=spec_to_u\umat';  % use fact that inverse of umat is the same as transpose of umat
end

ok=true;
mess='';
