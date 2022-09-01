function change_crystal(filenames,varargin)
% Change the crystal lattice and orientation of an sqw object stored in a file
% or array of files
%
% Most commonly:
%   >> change_crystal (filenames, rlu_corr)              % change lattice parameters and orientation
%
% OR
%   >> change_crystal (filenames, alatt)                 % change just length of lattice vectors
%   >> change_crystal (filenames, alatt, angdeg)         % change all lattice parameters
%   >> change_crystal (filenames, alatt, angdeg, rotmat) % change lattice parameters and orientation
%   >> change_crystal (filenames, alatt, angdeg, u, v)   % change lattice parameters and redefine u, v
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


% This routine used to change the crystal in sqw files, when it overwrites the input file.

% Parse input
% -----------
if ischar(filenames)
    filenames = {filenames};
end

% Perform operations
for i=1:numel(filenames)
    ld = sqw_formats_factory.instance().get_loader(filenames{i});
    data    = ld.get_data();
    target_file = fullfile(ld.filepath,ld.filename);
    ld = ld.set_file_to_update(target_file);
    alatt0 = data.alatt;
    angdeg0 = data.angdeg;
    if ld.sqw_type
        exp_info= ld.get_header('-all');
        [alatt,angdeg,rlu_corr]=SQWDnDBase.parse_change_crystal_arguments(alatt0,angdeg0,exp_info,varargin{:});
        exp_info = change_crystal(exp_info,alatt,angdeg,rlu_corr);
        ld = ld.put_headers(exp_info);
        ld = ld.put_samples(exp_info.samples);
    else
        [alatt,angdeg,rlu_corr]=SQWDnDBase.parse_change_crystal_arguments(alatt0,angdeg0,[],varargin{:});
    end
    data= data.change_crystal(alatt,angdeg,rlu_corr,'-parsed');
    ld = ld.put_dnd_metadata(data);
    ld.delete();
end
