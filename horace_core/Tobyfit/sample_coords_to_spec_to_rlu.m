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
samples = header.samples;
nrun=numel(samples);
sample=samples{1};
alatt=sample.alatt;
angdeg=sample.angdeg;
for i=2:nrun
    if ~isequal(sample,samples{i})
        ok=false;
        error('HORACE:sample_coords_to_spec_to_rlu:invalid_argument', ...
            'Sample description must be identical for all contributing spe files');
        return
    end
    if ~all(alatt==samples{i}.alatt) || ~all(angdeg==samples{i}.angdeg)
        ok=false;
        error('HORACE:sample_coords_to_spec_to_rlu:invalid_argument', ...
            'Lattice parameters must be identical for all contributing spe files');
        return
    end
end

% Fill s_mat
xgeom=sample.xgeom;
ygeom=sample.ygeom;
s_mat=zeros(3,3,nrun);
spec_to_rlu=zeros(3,3,nrun);
for i=1:nrun
    %if nrun~=1
        s=samples{i};
        e=header.expdata(i);
    %else
    %    h=header;
    %end
    % Matrix to convert from laboratory frame to crystal Cartesian coordinates, and to rlu
    [spec_to_u, ~, spec_to_rlu(:,:,i)]=calc_proj_matrix (s.alatt, s.angdeg, e.cu, e.cv, ...
                                                         e.psi, e.omega, e.dpsi, e.gl, e.gs); % Vcryst = spec_to_u * Vspec
    % Matrix to convert from crystal Cartesian coordinates to frame defined by sample geometry (x,y axes in r.l.u.)
    b=bmatrix(s.alatt, s.angdeg);
    [~,~,umat]=ubmatrix(xgeom, ygeom, b);   % Vsamp(i) = umat * Vcryst
    % Matrix to convert from sample coordinate frame to laboratory frame
    s_mat(:,:,i)=spec_to_u\umat';  % use fact that inverse of umat is the same as transpose of umat
end

ok=true;
mess='';
