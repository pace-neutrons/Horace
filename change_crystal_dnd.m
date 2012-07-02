function varargout=change_crystal_dnd(varargin)
% Change the crystal lattice and orientation in a file or set of files containing dnd information
% 
%   >> change_crystal (file, alatt)                 % change just length of lattice vectors
%   >> change_crystal (file, alatt, angdeg)         % change all lattice parameters
%   >> change_crystal (file, alatt, angdeg, rotmat) % change lattice parameters and orientation
% OR (more usually)
%   >> change_crystal (file, rlu_corr)              % change lattice parameters and orientation
%
% The altered object is written to the same file.
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%
%   alatt       New lattice parameters [a,b,c] (Angstroms)
%   angdeg      New lattice angles [alf,bet,gam] (degrees)
%   rotmat      Rotation matrix that relates crystal Cartesian coordinate frame of the new
%              lattice as a rotation of the current crystal frame. Orthonormal coordinates
%              in the two frames are related by 
%                   v_new(i)= rotmat(i,j)*v_current(j)
%
%   rlu_corr    Matrix to convert notional rlu in the current crystal lattice to
%              the rlu in the the new crystal lattice together with any re-orientation
%              of the crystal. The matrix is defined by the matrix:
%                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%               This matrix can be obtained from refining the lattice and
%              orientation with the function refine_crystal (type
%              >> help refine_crystal  for more details).

% Original author: T.G.Perring
%
% $Revision: 521 $ ($Date: 2011-01-16 09:45:59 +0000 (Sun, 16 Jan 2011) $)

% Catch case of dnd object
if nargin>=1 && nargin<=4 && (isa(varargin{1},'d0d')||isa(varargin{1},'d1d')||...
        isa(varargin{1},'d2d')||isa(varargin{1},'d3d')||isa(varargin{1},'d4d'))
    if nargout==0
        change_crystal(varargin{:})
    else
        varargout{1}=change_crystal(varargin{:});
    end
    return
    
elseif nargin>=1 && nargin<=4 && isa(varargin{1},'sqw')
    error('Input cannot be an sqw object')
    
elseif nargin<1 ||nargin>4
    error('Check number of input arguments')
    
elseif nargout>0
    error('No output arguments returned by this function')
end

% Check file name(s), prompting if necessary
[file_internal,mess]=getfile_horace(varargin{1});
if ~isempty(mess)
    error(mess)
end

% Perform action
function_dnd(file_internal,@change_crystal,varargin{2:end});
