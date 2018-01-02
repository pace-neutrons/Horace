function [mod_opts,ok,mess] = tobyfit_refine_moderator_options(varargin)
% Set up options to control the refinement of moderator pulse width parameters
% in Tobyfit. The output is a structure of options to be passed as follows:
%
%   >> opts = tobyfit_refine_moderator_options (...)   % see below for useage
%   >> [wout,fit]=tobyfit(...,'refine_moderator',opts,...)
%
% Use current moderator lineshape, with current parameters as initial values:
%   >> opts = tobyfit_refine_moderator_options
%   >> opts = tobyfit_refine_moderator_options (pp_free)                % logical list of parameters to refine
%
% Set moderator pulse shape model and/or parameters different to those in the sqw objects:
%   >> opts = tobyfit_refine_moderator_options ('',pp_init)             % retain model; new initial parameters
%   >> opts = tobyfit_refine_moderator_options (pulse_model,pp_init)    % new model and initial parameters
%   >> opts = tobyfit_refine_moderator_options (...,pp_free)            % and logical list of parameters to refine
%
%
% Input:
% ------
% Optional input parameters:
%   pulse_model     Name of moderator pulse shape model
%                   If empty e.g. [] or '' or omitted then current value in sqw objects is used (default)
%   pp_init         Initial pulse shape parameters
%                   If empty or omitted then current values in sqw objects are used
%   pp_free         Array of ones and zeros that indicates which parameters are to be refined:
%                     - 1 to refine the corresponding parameter
%                     - 0 to fix the corresponding parameter
%                   If empty or omitted then all parameters are free
%
%
% Output:
% -------
%   opts            Structure with moderator refinement options
%               pulse_model Name of moderator pulse shape model
%                          (=[] to use values in sqw objects)
%               pp_init     Initial pulse shape parameters (row vector)
%                          (=[] to use values in sqw objects)
%               pp_free     Logical row vector of zeros and ones
%                          (=[] for all to be free)
%
%
% EXAMPLES
%   Refine all parameters in the moderator model in the sqw opbject(s):
%   >> opts = tobyfit_refine_moderator_options
%
%   Specify a model and parameters:
%   >> tauf=5; taus=25; R=0.3;
%   >> opts = tobyfit_refine_moderator_options('ikcarp',[tauf,taus,R])
%
%   ...allowing only tauf to vary:
%   >> tauf=5; taus=25; R=0.3;
%   >> opts = tobyfit_refine_moderator_options('ikcarp',[tauf,taus,R],[1,0,0])


% For use in other routines: pass a structure and check that it is a valid
% opts strcuture:
%   >> [opts,ok,mess] = tobyfit_refine_moderator_options(struct)


% Get moderator refinement options structure
% ------------------------------------------
% Determine if options structure input or not
if nargin==1 && isstruct(varargin{1})   % input a single structure
    if isscalar(varargin{1})
        [mod_opts,ok,mess]=check_ok(varargin{1});
        if nargout>1, return, else error(mess), end
    else
        mod_opts=check_ok; ok=false; mess='Structure with moderator refinement options must be a scalar structure';
        if nargout>1, return, else error(mess), end
    end
    
else
    mod_opts=check_ok;     % structure with fields all set to []
    
    % Check if initial lattice parameters for refinement, if given
    if numel(varargin)==1 && (isnumeric(varargin{1})||islogical(varargin{1}))  % catch likely mistakes a user might make
        mod_opts.pp_free=varargin{1};
    else
        if numel(varargin)>=1, mod_opts.pulse_model=varargin{1}; end
        if numel(varargin)>=2, mod_opts.pp_init=varargin{2}; end
        if numel(varargin)>=3, mod_opts.pp_free=varargin{3}; end
        if numel(varargin)>=4
            mod_opts=check_ok; ok=false; mess='Check number of input arguments';
            if nargout>1, return, else error(mess), end
        end
    end
    
    % Check validity of structure
    [mod_opts,ok,mess]=check_ok(mod_opts);
    if nargout>1, return, else error(mess), end
    
end

%--------------------------------------------------------------------------------------------------
function [mod_opts,ok,mess]=check_ok(mod_opts_in)
% Check validity of moderator options structure, setting defaults for empty fields where possible
%
%   >> [mod_opts,ok,mess]=check_ok(mod_opts_in)
%   >> [mod_opts,ok,mess]=check_ok
%
% If not valid (or no input argument), then returns a 1x1 structure with the fields
% all set to []

names={'pulse_model';'pp_init';'pp_free'};     % valid names

% Catch case of forced error
% --------------------------
if nargin==0
    mod_opts=empty_struct(names);
    ok=false; mess='Returning default error structure'; return
end


% Check structure has correct names
% ---------------------------------
if ~isequal(fieldnames(mod_opts_in),names)
    mod_opts=empty_struct(names);
    ok=false; mess='Moderator refinement options structure does not have the correct fields'; return
end


% Check input
% -----------
mod_opts=mod_opts_in;

% Check name
if isempty(mod_opts.pulse_model)
    mod_opts.pulse_model=[];
elseif ~is_string(mod_opts.pulse_model)
    mod_opts=empty_struct(names);
    ok=false; mess='Check moderator pulse shape name for refinement is a character string'; return
end

% Check initial parameter values
if ~isempty(mod_opts.pp_init) && isnumeric(mod_opts.pp_init)
    if ~isrowvector(mod_opts.pp_init)
        mod_opts.pp_init=mod_opts.pp_init(:)';
    end
elseif isempty(mod_opts.pp_init)
    mod_opts.pp_init=[];
else
    mod_opts=empty_struct(names);
    ok=false; mess='Check initial moderator pulse shape parameters for refinement'; return
end

% Check free parameters
if islognum(mod_opts.pp_free)
    if ~islogical(mod_opts.pp_free)
        mod_opts.pp_free=logical(mod_opts.pp_free);
    end
    if ~isrowvector(mod_opts.pp_free)
        mod_opts.pp_free=mod_opts.pp_free(:)';
    end
elseif isempty(mod_opts.pp_free)
    mod_opts.pp_free=[];
else
    mod_opts=empty_struct(names);
    ok=false; mess='Check the free/fixed parameter list for refinement is an array of logicals'; return
end

% Check mutual consistency of parameters
if ~isempty(mod_opts.pulse_model) && isempty(mod_opts.pp_init)
    mod_opts=empty_struct(names);
    ok=false; mess='If the moderator pulse shape name for refinement is given, you must give the initial parameter values'; return
elseif ~isempty(mod_opts.pp_init)
    if isempty(mod_opts.pp_free)
        mod_opts.pp_free=true(size(mod_opts.pp_init));
    elseif numel(mod_opts.pp_free)~=numel(mod_opts.pp_init)
        mod_opts=empty_struct(names);
        ok=false; mess='The number of moderator pulse shape parameters for refinement is inconsistent with the fixed/free parameter list'; return
    end
end

% If one has been given, check the moderator model is recognised by the pulse_shape method
if ~isempty(mod_opts.pulse_model)
    try
        dummy_mod=IX_moderator;
        dummy_mod.pulse_model=mod_opts.pulse_model;
        dummy_mod.pp=mod_opts.pp_init;
        dummy_ei=10;
        dummy_val=pulse_shape(dummy_mod,dummy_ei,0);    % evaluate at t=0
    catch
        mod_opts=empty_struct(names);
        ok=false; mess='The moderator pulse shape model for refinement is not recognised or the initial parameter value array is not valid'; return
    end
end


% OK if got to here
ok=true;
mess='';

%--------------------------------------------------------------------------------------------------
function s=empty_struct(names)
% Create scalar structure with input fields and all values set to []
args=[names(:)';repmat({[]},1,numel(names))];
s=struct(args{:});
