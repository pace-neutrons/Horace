function varargout = refine_crystal_sqw(varargin)
% Refine crystal orientation and lattice parameters for an sqw object.
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
%
% For full details of the arguments, type:
%
%   >> help sqw/refine_crystal
%
% The help is identical.

% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)

[varargout,mess] = horace_function_call_method (nargout, @refine_crystal, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end
