function [xtal_opts,ok,mess] = refine_crystal_parse (varargin)
% Set up options to control the refinement of crystal orientation and lattice parameters
% in Tobyfit. The output is a structure of options to be passed as follows:
%
% Default options:
%   >> [xtal_opts,ok,mess] = refine_crystal_parse
%
% Set initial lattice parameters different to those in the sqw objects
%   >> [xtal_opts,ok,mess] = refine_crystal_parse (alatt_init, angdeg_init)
%
% In addition, there are keyword arguments to control the refinement e.g.
%   >> [xtal_opts,ok,mess] = refine_crystal_parse (..., 'fix_angdeg',...)
%   >> [xtal_opts,ok,mess] = refine_crystal_parse (..., 'free_alatt', [1,0,1],...)
%
% By default, all parameters are free to be refined.
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
%
% Output:
% -------
%   xtal_opts       Structure with crystal refinement options
%           alatt   Initial lattice parameters (=[] to use values in sqw objects)
%           angdeg  Initial lattice angles (=[] to use values in sqw objects)
%           rot     Initial rotation vector (rad) (=[0,0,0])
%           urot    x-axis in r.l.u. (Default: [1,0,0])
%           vrot    Defines y-axis in r.l.u. (in plane of urot and vrot)
%                  (Default: [0,1,0])
%           pfree   Logical row vector (length=9); true for free parameters
%                  (Default: all free)
%           fix_alatt_ratio     =true if a,b,c are to be bound (Default: false)
%
%                   If there is a problem, then all fields are set to [].


% For use within other routines: pass a structure and check that it is a valid
% opts strcuture, expandng any empty fields to the defaults:
%   >> [xtal_opts,ok,mess] = refine_crystal_parse (xtal_opts)


% Get crystal refinement options structure
% ----------------------------------------
% Determine if xtal_opts structure input or not
if nargin==1 && isstruct(varargin{1})   % input a single structure
    if isscalar(varargin{1})
        [xtal_opts,ok,mess]=check_ok(varargin{1});
        if nargout>1, return, else error(mess), end
    else
        xtal_opts=check_ok; ok=false; mess='Structure with crystal refinement options must be a scalar structure';
        if nargout>1, return, else error(mess), end
    end
    
else
    xtal_opts=check_ok;     % structure with fields all set to []
    
    % Parse input
    arglist=struct('fix_lattice',0,'fix_alatt',0,'fix_alatt_ratio',0,'fix_angdeg',0,'fix_orientation',0,'free_alatt',[1,1,1],'free_angdeg',[1,1,1]);
    flags={'fix_lattice','fix_alatt','fix_alatt_ratio','fix_angdeg','fix_orientation'};
    [args,opt,present] = parse_arguments(varargin,arglist,flags);
    
    % Check if initial lattice parameters for refinement, if given
    if numel(args)>=1, xtal_opts.alatt=args{1};  end
    if numel(args)>=2, xtal_opts.angdeg=args{2}; end
    if numel(args)>=3, xtal_opts.urot=args{3};   end
    if numel(args)>=4, xtal_opts.vrot=args{4};   end
    if numel(args)>=5
        xtal_opts=check_ok; ok=false; mess='Check number of input arguments';
        if nargout>1, return, else error(mess), end
    end
    
    % Check options
    if present.free_alatt
        if islognum(opt.free_alatt) && numel(opt.free_alatt)==3
            if opt.fix_lattice || opt.fix_alatt || opt.fix_alatt_ratio
                xtal_opts=check_ok; ok=false; mess='Cannot use the option ''free_alatt'' with other keywords fixing lattice parameters a,b,c';
                if nargout>1, return, else error(mess), end
            end
        else
            xtal_opts=check_ok; ok=false; mess='Check value of ''free_alatt'' option';
            if nargout>1, return, else error(mess), end
        end
    end
    
    if present.free_angdeg
        if islognum(opt.free_angdeg) && numel(opt.free_angdeg)==3
            if opt.fix_lattice || opt.fix_angdeg
                xtal_opts=check_ok; ok=false; mess='Cannot use the option ''free_angdeg'' with other keywords fixing lattice parameters alf,bet,gam';
                if nargout>1, return, else error(mess), end
            end
        else
            xtal_opts=check_ok; ok=false; mess='Check value of ''free_angdeg'' option';
            if nargout>1, return, else error(mess), end
        end
    end
    
    if opt.fix_lattice && ...
            ((present.fix_alatt && ~opt.fix_alatt) || (present.fix_angdeg && ~opt.fix_angdeg) || (present.fix_alatt_ratio && ~opt.fix_alatt_ratio))
        xtal_opts=check_ok; ok=false; mess='Check consistency of options to fix lattice parameters';
        if nargout>1, return, else error(mess), end
    elseif opt.fix_alatt && (present.fix_alatt_ratio && ~opt.fix_alatt_ratio)
        xtal_opts=check_ok; ok=false; mess='Check consistency of options to fix lattice parameters';
        if nargout>1, return, else error(mess), end
    end
    
    % Create arrays of free parameters and bindings
    pfree=[1,1,1,1,1,1,1,1,1];
    fix_alatt_ratio=false;
    
    if opt.fix_alatt || opt.fix_lattice
        pfree(1:3)=[0,0,0];
    elseif opt.fix_alatt_ratio
        fix_alatt_ratio=true;
    elseif present.free_alatt
        pfree(1:3)=opt.free_alatt;
    end
    
    if opt.fix_angdeg || opt.fix_lattice
        pfree(4:6)=[0,0,0];
    elseif present.free_angdeg
        pfree(4:6)=opt.free_angdeg;
    end
    
    if opt.fix_orientation
        pfree(7:9)=[0,0,0];
    end
    
    % Add to structure
    xtal_opts.pfree=logical(pfree);
    xtal_opts.fix_alatt_ratio=fix_alatt_ratio;
    
    % Check validity of structure
    [xtal_opts,ok,mess]=check_ok(xtal_opts);
    if nargout>1, return, else error(mess), end

end

%--------------------------------------------------------------------------------------------------
function [xtal_opts,ok,mess]=check_ok(xtal_opts_in)
% Check validity of crystal options structure, setting defaults for empty fields where possible
%
%   >> [xtal_opts,ok,mess]=check_ok(xtal_opts_in)
%   >> [xtal_opts,ok,mess]=check_ok
%
% If not valid (or no input argument), then returns a 1x1 structure with the fields
% all set to []

names={'alatt';'angdeg';'rot';'urot';'vrot';'pfree';'fix_alatt_ratio'};     % valid names

% Catch case of forced error
% --------------------------
if nargin==0
    xtal_opts=empty_struct(names);
    ok=false; mess='Returning default error structure'; return
end


% Check structure has correct names
% ---------------------------------
if ~isequal(fieldnames(xtal_opts_in),names)
    xtal_opts=empty_struct(names);
    ok=false; mess='Crystal refinement options structure does not have the correct fields'; return
end
    
    
% Check input
% -----------
xtal_opts=xtal_opts_in;

% Check lattice parmeters
if numel(xtal_opts.alatt)==3 && isnumeric(xtal_opts.alatt) && all(xtal_opts.alatt>0)
    if ~isrowvector(xtal_opts.alatt)
        xtal_opts.alatt=xtal_opts.alatt(:)';
    end
elseif isempty(xtal_opts.alatt)
    xtal_opts.alatt=[];
else
    xtal_opts=empty_struct(names);
    ok=false; mess='Check initial lattice parameters ([a,b,c]) for refinement'; return
end

% Check lattice angles
if numel(xtal_opts.angdeg)==3 && isnumeric(xtal_opts.angdeg) && all(xtal_opts.angdeg>0)
    if ~isrowvector(xtal_opts.angdeg)
        xtal_opts.angdeg=xtal_opts.angdeg(:)';
    end
elseif isempty(xtal_opts.angdeg)
    xtal_opts.angdeg=[];
else
    xtal_opts=empty_struct(names);
    ok=false; mess='Check initial lattice angles ([alf,bet,gam]) for refinement'; return
end

% Check rotation vector
if numel(xtal_opts.rot)==3 && isnumeric(xtal_opts.rot)
    if ~isrowvector(xtal_opts.rot)
        xtal_opts.rot=xtal_opts.rot(:)';
    end
elseif isempty(xtal_opts.rot)
    xtal_opts.rot=[0,0,0];
else
    xtal_opts=empty_struct(names);
    ok=false; mess='Check initial rotation vector ([angx,angy,angz]) for refinement'; return
end

% Check urot and vrot
if numel(xtal_opts.urot)==3 && isnumeric(xtal_opts.urot) && ~all(abs(xtal_opts.urot)<1e-10)
    if ~isrowvector(xtal_opts.urot)
        xtal_opts.urot=xtal_opts.urot(:)';
    end
elseif isempty(xtal_opts.urot)
    xtal_opts.urot=[1,0,0];
else
    xtal_opts=empty_struct(names);
    ok=false; mess='Check vector defining x-axis of crystal rotation'; return
end

if numel(xtal_opts.vrot)==3 && isnumeric(xtal_opts.vrot) && ~all(abs(xtal_opts.vrot)<1e-10)
    if ~isrowvector(xtal_opts.vrot)
        xtal_opts.vrot=xtal_opts.vrot(:)';
    end
elseif isempty(xtal_opts.vrot)
    xtal_opts.vrot=[0,1,0];
else
    xtal_opts=empty_struct(names);
    ok=false; mess='Check vector defining y-axis of crystal rotation'; return
end

if norm(cross(xtal_opts.urot,xtal_opts.vrot))/(norm(xtal_opts.urot)*norm(xtal_opts.vrot)) < 1e-5
    xtal_opts=empty_struct(names);
    ok=false; mess='Vectors defining x and y axes of crystal rotation are colinear, or almost colinear'; return
end

% Check free parameter list and fix_alatt_ratio option
if islognum(xtal_opts.pfree) && numel(xtal_opts.pfree)==9
    xtal_opts.pfree=logical(xtal_opts.pfree(:)');
else
    xtal_opts=empty_struct(names);
    ok=false; mess='List of free parameters must be array length=9 of logicals, or numeric 0 or 1'; return
end

if islognumscalar(xtal_opts.fix_alatt_ratio)
    if ~islogical(xtal_opts.fix_alatt_ratio), xtal_opts.fix_alatt_ratio=logical(xtal_opts.fix_alatt_ratio); end
    if xtal_opts.fix_alatt_ratio && ~all(xtal_opts.pfree(2:3))
        xtal_opts=empty_struct(names);
        ok=false; mess='Option fix_alatt_ratio requires that lattice parameters b and c are free to vary'; return
    end
else
    xtal_opts=empty_struct(names);
    ok=false; mess='Option fix_alatt_ratio must be true or false, or 0 or 1'; return
end

% OK if got to here
ok=true;
mess='';

%--------------------------------------------------------------------------------------------------
function s=empty_struct(names)
% Create scalar structure with input fields and all values set to []
args=[names(:)';repmat({[]},1,numel(names))];
s=struct(args{:});
