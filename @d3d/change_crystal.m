function varargout = change_crystal(varargin)
% Change the crystal lattice and orientation of a d3d object or array of objects
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
%   w           Input d3d object
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
% Output:
% -------
%   wout        Output d3d object with changed crystal lattice parameters and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)
%    - call with the original alatt, angdeg, u and v


% Original author: T.G.Perring
%
% $Revision: 519 $ ($Date: 2011-01-12 11:46:43 +0000 (Wed, 12 Jan 2011) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type


% If data source is a filename or data_source structure, then must ensure that matches dnd type
[data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = parse_data_source (sqw(varargin{1}), varargin{2:end});
if ~isempty(mess)
    error(mess)
end
if source_is_file   % either file names or data_source structure as input
    if any(sqw_type) || any(ndims~=dimensions(varargin{1}(1)))     % must all be the required dnd type
        error(['Data file(s) not (all) ',classname,' type i.e. no pixel information'])
    end
    if nargout>0
        error('Cannot have output for data source being file(s)')
    end
end

% Now call sqw head routine
if source_is_file
    change_crystal(sqw,data_source,args{:});
else
    varargout{1}=dnd(change_crystal(sqw(data_source),args{:}));
end
