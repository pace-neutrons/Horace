function varargout = change_crystal (varargin)
% Change the crystal lattice and orientation of a d1d object or array of objects
%
% Most commonly:
%   >> wout = change_crystal (w, rlu_corr)              % change lattice parameters and orientation
%
% OR
%   >> wout = change_crystal (w, alatt)                 % change just length of lattice vectors
%   >> wout = change_crystal (w, alatt, angdeg)         % change all lattice parameters
%   >> wout = change_crystal (w, alatt, angdeg, rotmat) % change lattice parameters and orientation
%
%
% Input:
% -----
%   w           Input d1d object
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
%
% Output:
% -------
%   wout        Output d1d object with changed crystal lattice parameters and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)


% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
% Now call sqw cut routine. Output (if any), is a cell array, as method is passed a data source structure
if numel(args)>3, error('Check number of input arguments'), end     % catch case of u,v passed from *_horace 
argout=change_crystal(sqw,w,args{:});
if ~isempty(argout)
    argout{1}=dnd(argout{1});   % as return argument is sqw object of dnd-type
end

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
