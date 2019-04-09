function varargout = refine_crystal (varargin)
% Refine crystal orientation and lattice parameters for a d4d object.
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
% The help is identical, except here the input object is a d4d object


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
% Now call sqw cut routine. Output (if any), is a cell array, as method is passed a data source structure
argout=refine_crystal(sqw,w,args{:});

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
