function obj = set_refine_crystal (obj, varargin)
% Set the options for refining crystal orientation and lattice parameters
%
% No refinement
%   >> obj = obj.set_refine_crystal (false)
%
% Refine using current orientation and lattice parameters as initial values:
%   >> obj = obj.set_refine_crystal
%   >> obj = obj.set_refine_crystal (true)
%
% Set initial lattice parameters different to those in the sqw objects
%   >> obj = obj.set_refine_crystal (alatt_init, angdeg_init)
%
% Set x, y axes for rotation matrix to somethng other than defaults:
%   >> obj = obj.set_refine_crystal ([], [], urot, vrot)
%
% Set both lattice parmaeters and rotation matrix axes
%   >> obj = obj.set_refine_crystal (alatt_init, angdeg_init, urot, vrot)
%
% In addition, there are keyword arguments to control the refinement e.g.
%   >> obj = obj.set_refine_crystal (..., 'fix_angdeg',...)
%   >> obj = obj.set_refine_crystal (..., 'free_alatt', [1,0,1],...)
%
% Alternatively, set the above using the refine crystal options as previously
% set:
%   >> xtal_opts = obj.refine_crystal (...);
%           :
%   >> obj = obj.refine_crystal (xtal_opts)
%
%
% Input:
% ------
% Optional input parameters:
%   alatt_init      Initial lattice parameters for start of refinement
%                  i.e. [a,b,c] (Angstroms)
%                   If empty e.g. [] or '' or omitted then current values
%                  in sqw objects are used
%
%   angdeg_init     Initial lattice angles for start of refinement
%                  i.e. [alf,bet,gam] (deg)
%                   If one or both of alatt_init and angdeg_init are not given,
%                  then the corresponding reference lattice parmaeters are
%                  taken as the initial values for refinement.
%                   If empty e.g. [] or '' or omitted then current values
%                  in sqw objects are used
%
%   urot            Direction of x-axis for rotation matrix in r.l.u.
%                   If empty or omitted , takes default as [1,0,0]
%
%   vrot            Direction of y-axis for rotation matrix in r.l.u. (if
%                  not perpendicular to urot, then the y-axis will be
%                  constructed in the usual fashion as being in the plane of
%                  urot and vrot with vrot habving a positive component along
%                  the y axis)
%                   If empty or omitted, then takes the default [0,1,0]
%
% Keywords (more than one is permitted so long as the keywords are consistent)
%   fix_lattice     Fix all lattice parameters [a,b,c,alf,bet,gam]
%                  i.e. only allow crystal orientation to be refined
%
%   fix_alatt       Fix [a,b,c] but allow lattice angles alf, bet and gam
%                  to be refined together with crystal orientation
%
%   fix_angdeg      Fix [alf,bet,gam] but allow pattice parameters [a,b,c]
%                  to be refined together with crystal orientation
%
%   fix_alatt_ratio Fix the ratio of the lattice parameters as given by the
%                  values in lattice_init, but allow the overall scale of the
%                  lattice to be refined together with crystal orientation
%
%   fix_orient      Fix the crystal orientation i.e. only refine lattice
%                  parameters
%
% Finer control of refinement of lattice parameters: instead of fix_lattice,
% fix_angdeg,... use
%   free_alatt      Array length 3 of zeros or ones, 1=free, 0=fixed
%                  e.g. ...,'free_alatt',[1,0,1],...
%                   allows only lattice parameter b to vary
%
%   free_angdeg     Array length 3 of zeros or ones, 1=free, 0=fixed
%                  e.g. ...,'free_lattice',[1,1,0],...
%                   fixes lattice angle gam buts allows alf and bet to vary
%
% EXAMPLES
%   Want to refine crystal orientation only:
%   >> obj = obj.set_refine_crystal ('fix_lattice')
%
%   Want to refine lattice parameters a,b,c as well as crystal orientation:
%   >> obj = obj.set_refine_crystal ('fix_angdeg')
%
%   ...with particular starting values for the lattice parameters
%   >> obj = obj.set_refine_crystal ([4.227,4.227,13.3],'fix_angdeg')


if numel(varargin)==1 && islognumscalar(varargin{1}) && ~logical(varargin{1})
    obj.refine_crystal_ = [];
else
    if isempty(obj.refine_moderator_)
        % -------------------------------------------------------------------------------
        % Check there is data
        data = obj.data;
        if ~isempty(data)
            if iscell(data)     % might be a single sqw object
                wsqw = cell2mat_obj(cellfun(@(x)x(:),data,'UniformOutput',false));
            else
                wsqw = data;
            end
        else
            error('No data sets have been set - not possible to set moderator refinement options')
        end
        % Check that the lattice parameters are the same in all objects
        [alatt0,angdeg0,ok,mess] = lattice_parameters(wsqw);
        if ~ok
            mess=['Crystal refinement: ',mess];
            error(mess)
        end
        % Fill crystal options
        if numel(varargin)==0 || (numel(varargin)==1 &&...
                (isempty(varargin{1}) || (islognumscalar(varargin{1}) && logical(varargin{1}))))
            [xtal_opts,ok,mess] = refine_crystal_parse (alatt0,angdeg0);
        else
            [xtal_opts,ok,mess] = refine_crystal_parse (alatt0,angdeg0,varargin{:});
        end
        if ok
            obj.refine_crystal_ = xtal_opts;
        else
            error(mess)
        end
    else
        error('Cannot set refine_crystal if refine_moderator has been set')
    end
end
