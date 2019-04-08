function varargout = refine_crystal (varargin)
% Refine crystal orientation and lattice parameters for an sqw or d0d/d1d/...d4d object
%
%   >> [rlu_corr,alatt,angdeg] = refine_crystal(w, rlu0, rlu)
%   >> [rlu_corr,alatt,angdeg] = refine_crystal(w, rlu0, rlu, alatt_init, angdeg_init)
%
% In addition, there are keyword arguments to control the refinement e.g.
%   >> [rlu_corr,alatt,angdeg] = refine_crystal(..., 'fix_angdeg')
%   >> [rlu_corr,alatt,angdeg] = refine_crystal(..., 'free_alatt', [1,0,1])
%
% In all cases, further output arguments can be returned:
%   >> [rlu_corr,alatt,angdeg,rotmat,distance,rotangle] = refine_crystal(...)
%
% This function is used to get a matrix that relates the coordinates of a vector (h0,k0,l0)
% as expressed in an initial or reference lattice to the coordinates (h,k,l) in the true lattice.
% It does this by taking a set of points (h0,k0,l0) and the corresponding set of true indices
% (h,k,l), and refining the lattice parameters and orientation. The refined lattice parameters
% are also returned.
%
% The output from this function can be used to correct the crystal orientation and lattice parameters
% in Horace. Type >> help change_crystal_horace for more details.
%
% Input:
% ------
%   w               sqw object
%   rlu0            Positions of reciprocal lattice vectors as h,k,l in reference lattice
%                  (n x 3 matrix, n=no. reflections)
%   rlu             True indexes of reciprocal lattice vectors (n x 3 matrix)
%
% Optional input parameter:
%   alatt_init      Initial lattice parameters for start of refinement [a,b,c] (Angstroms)
%   angdeg_init     Initial lattice angles for start of refinement [alf,bet,gam] (deg)
%                  If one or both of alatt_init and angdeg_init are not given, then the corresponding
%                  reference lattice parameters are taken as the initial values for refinement.
%
% Keywords (more than one is permitted if not inconsistent)
%   fix_lattice     Fix all lattice parameters [a,b,c,alf,bet,gam]
%                  i.e. only allow crystal orientation to be refined
%   fix_alatt       Fix [a,b,c] but allow lattice angles alf, bet and gam to be refined
%                  together with crystal orientation
%   fix_angdeg      Fix [alf,bet,gam] but allow lattice parameters [a,b,c] to be refined
%                  together with crystal orientation
%   fix_alatt_ratio Fix the ratio of the lattice parameters as given by the values in
%                  lattice_init, but allow the overall scale of the lattice to be refined
%                  together with crystal orientation
%   fix_orient      Fix the crystal orientation i.e. only refine lattice parameters
%
% Finer control of refinement of lattice parameters: instead of fix_lattice, fix_angdeg,... use
%   free_alatt      Array length 3 of zeros or ones, 1=free, 0=fixed
%                  e.g. ...,'free_alatt',[1,0,1],... allows only lattice parameter b to vary
%   free_angdeg     Array length 3 of zeros or ones, 1=free, 0=fixed
%                  e.g. ...,'free_lattice',[1,1,0],... fixes lattice angle gam buts allows alf and bet to vary
%
%
% Output:
% -------
%   rlu_corr        Conversion matrix to relate notional rlu to true rlu, accounting for the the
%                  refined crystal lattice parameters and orientation
%                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%
%   alatt           Refined lattice parameters [a,b,c] (Angstroms)
%
%   angdeg          Refined lattice angles [alf,bet,gam] (degrees)
%
%   rotmat          Rotation matrix that relates crystal Cartesian coordinate frame of the refined
%                  lattice and orientation as a rotation of the initial crystal frame. Coordinates
%                  in the two frames are related by 
%                       v(i)= rotmat(i,j)*v0(j)
%
%   distance        Distances between peak positions and points given by true indexes, in input
%                  argument rlu, in the refined crystal lattice. (Ang^-1)
%
%   rotangle        Angle of rotation corresponding to rotmat (to give a measure
%                  of the misorientation) (degrees)
%
% The output argument rlu_corr, together with the input alatt0 and angdeg0, are sufficient to compute
% the other output arguments. That is why Horace functions that use the output of this function will
% generally only require rlu_corr.
%
% EXAMPLES
%   Want to refine crystal orientation only:
%   >> rlu_corr=refine_crystal (rlu0, alatt0, angdeg0, rlu, 'fix_lattice')
%
%   Want to refine lattice parameters a,b,c as well as crystal orientation:
%   >> [rlu_corr,alatt]=refine_crystal (rlu0, alatt0, angdeg0, rlu, 'fix_angdeg')


% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)


% This routine is also used to change the crystal in sqw files, for which the syntax is
%   >> change_crystal(filename,...)
% and the output overwrites the input file.

% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
if numel(w.data)>1
    error('Only a single data source must be provided')
elseif numel(args)<2
    error('Check number of input arguments')
end

h=head_horace(horace_function_squeeze_datasource(w));
alatt0=h.alatt;
angdeg0=h.angdeg;

[rlu_corr,alatt,angdeg,rotmat,distance,rotangle] = refine_crystal(args{1},alatt0,angdeg0,args{2:end});
argout={rlu_corr,alatt,angdeg,rotmat,distance,rotangle};


% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
