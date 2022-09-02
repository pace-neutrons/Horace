function wout = change_crystal(obj,varargin)
% Change the crystal lattice and orientation of an dnd object or array of objects
%
% Most commonly:
%   >> wout = change_crystal (w, rlu_corr)              % change lattice parameters and orientation
%
% OR
%   >> wout = change_crystal (w, alatt)                 % change just length of lattice vectors
%   >> wout = change_crystal (w, alatt, angdeg)         % change all lattice parameters
%   >> wout = change_crystal (w, alatt, angdeg, rotmat) % change lattice parameters and orientation
%   >> wout = change_crystal (w, alatt, angdeg, u, v)   % change lattice parameters and redefine u, v
% OR driven mode:
% %   >> wout = change_crystal (w, alatt, angdeg, rotmat,'-parsed') %
%               change lattice parameters and orientation when correct lattice
%               parameters and rotation matrix are already calculated
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
%               lattice as a rotation of the current crystal frame. Orthonormal coordinates
%               in the two frames are related by
%               v_new(i)= rotmat(i,j)*v_current(j)
%
% Output:
% -------
%   wout        Output dnd object with changed crystal lattice parameters and orientation


is_parsed = cellfun(@(x)(ischar(x)&&strcmp(x,'-parsed')),varargin);
if any(is_parsed) % driven mode
    alatt = varargin{1};
    angdeg = varargin{2};
    rlu_corr = varargin{3};
    if ~iscell(alatt)
        alatt = {alatt};
        angdeg = {angdeg};        
        rlu_corr = {rlu_corr};
    end
else
    alatt = cell(1,numel(obj));
    angdeg = cell(1,numel(obj));
    rlu_corr = cell(1,numel(obj));
    for i=1:numel(obj)
        alatt0 = obj(i).alatt;
        angdeg0 = obj(i).angdeg;
        [alatt{i},angdeg{i},rlu_corr{i}]=SQWDnDBase.parse_change_crystal_arguments(alatt0,angdeg0,[],varargin{:});
    end
end
wout = obj;
for i=1:numel(obj)
    wout(i).alatt=alatt{i};
    wout(i).angdeg=angdeg{i};
    u_to_rlu = wout(i).proj.u_to_rlu;
    wout(i).offset(1:3)=rlu_corr{i}*wout(i).offset(1:3)';
    wout(i).proj = wout(i).proj.set_from_data_mat(rlu_corr{i}*u_to_rlu(1:3,1:3),wout(i).axes.ulen);
end
