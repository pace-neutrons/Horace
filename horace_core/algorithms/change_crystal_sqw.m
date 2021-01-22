function change_crystal_sqw(filenames,varargin)
% Change the crystal lattice and orientation of an sqw object or array of objects
%
% Most commonly:
%   >> wout = change_crystal (w, rlu_corr)              % change lattice parameters and orientation
%
% OR
%   >> wout = change_crystal (w, alatt)                 % change just length of lattice vectors
%   >> wout = change_crystal (w, alatt, angdeg)         % change all lattice parameters
%   >> wout = change_crystal (w, alatt, angdeg, rotmat) % change lattice parameters and orientation
%   >> wout = change_crystal (w, alatt, angdeg, u, v)   % change lattice parameters and redefine u, v
%
%
% Input:
% -----
%   w           Input sqw object
%
%   rlu_corr    Matrix to convert notional rlu in the current crystal lattice to
%              the rlu in the the new crystal lattice together with any re-orientation
%              of the crystal. The matrix is defined by the matrix:
%                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%               This matrix can be obtained from refining the lattice and
%              orientation with the function refine_crystal (type
%              >> help refine_crystal  for more details).
% *OR*
%   alatt       New lattice parameters [a,b,c] (Angstroms)
%   angdeg      New lattice angles [alf,bet,gam] (degrees)
%   rotmat      Rotation matrix that relates crystal Cartesian coordinate frame of the new
%              lattice as a rotation of the current crystal frame. Orthonormal coordinates
%              in the two frames are related by
%                   v_new(i)= rotmat(i,j)*v_current(j)
%   u, v        Redefine the two vectors that were used to determine the scattering plane
%              These are the vectors at whatever disorientation angles dpsi, gl, gs (which
%              cannot be changed).
%
% Output:
% -------
%   wout        Output sqw object with changed crystal lattice parameters and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)
%    - call with the original alatt, angdeg, u and v

% Original author: T.G.Perring
%


% This routine is also used to change the crystal in sqw files, when it overwrites the input file.

% Parse input
% -----------
if ischar(filenames)
    filenames = {filenames};
end

% Perform operations
for i=1:numel(filenames)
    ld = sqw_formats_factory.instance().get_loader(filenames{i});
    data    = ld.get_data('-verbatim','-head');
    target_file = fullfile(ld.filepath,ld.filename);
    ld = ld.set_file_to_update(target_file);
    if ld.sqw_type
        headers = ld.get_header('-all');
        [headers,data]=change_crystal_alter_fields(headers,data,varargin{:});
        ld = ld.put_headers(headers);
    else
        headers = struct([]);
        [~,data]=change_crystal_alter_fields(headers,data,varargin{:});
    end
    ld = ld.put_dnd_metadata(data);
    ld.delete();
end
