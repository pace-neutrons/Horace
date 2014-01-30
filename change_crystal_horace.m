function varargout=change_crystal_horace(varargin)
% Change the crystal lattice and orientation in a file or set of files containing a Horace data object
% 
% Most commonly:
%   >> change_crystal (file, rlu_corr)              % change lattice parameters and orientation
%
% OR
%   >> change_crystal (file, alatt)                 % change just length of lattice vectors
%   >> change_crystal (file, alatt, angdeg)         % change all lattice parameters
%   >> change_crystal (file, alatt, angdeg, rotmat) % change lattice parameters and orientation
%
%   If sqw data, additionally:
%   >> change_crystal (file, alatt, angdeg, u, v)   % change lattice parameters and redefine u, v
%
% The altered object is written to the same file.
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
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
%              These are the vectors at whatever misorientation angles dpsi, gl, gs (which
%              cannot be changed).
%
% NOTE
%  The input data file(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)
%    - call with the original alatt, angdeg, u and v (if sqw-type data)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if nargin<1 ||nargin>5
    error('Check number of input arguments')
elseif nargout>0
    error('No output arguments returned by this function')
end

[varargout,mess] = horace_function_call_method (nargout, @change_crystal, '$hor', varargin{:});
if ~isempty(mess), error(mess), end
