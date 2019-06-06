function [mod_opts,ok,mess] = refine_moderator_parse (mod_opts_default,varargin)
% Set up options to control the refinement of moderator pulse width parameters
%
% Check a moderator options structure is valid:
%   >> [mod_opts,ok,mess] = refine_moderator_parse (mod_opts_default)
%
% Set which parameters to refine with a logical array of zeros and ones
%   >> [mod_opts,ok,mess] = refine_moderator_parse (mod_opts_default, free)
%
% Set pulse shape model parameters different to those in the sqw objects:
% - New initial parameters:
%   >> [mod_opts,ok,mess] = refine_moderator_parse (mod_opts_default, pin, free)
%
% - New model and initial parameters:
%   >> [mod_opts,ok,mess] = refine_moderator_parse (mod_opts_default, pulse_model, pin, free)
%
% Input:
% ------
%  mod_opts_default Default moderator options structure. Must have fields:
%                       pulse_model     Name of moderator pulse shape model
%                       pin             Pulse shape parameters
%                       free            Logical array indicating free (true) or
%                                      fixed (false) for each parameter.
%                   If the default moderator options structure is used to fill
%                  any fields in the output options structure, it must be a
%                  valid options structure
%
% Optional input parameters:
%   pulse_model     Name of moderator pulse shape model
%                   If empty e.g. [] or '' or omitted then the value in the default is used
%
%   pin             Initial pulse shape parameters
%                   If empty or omitted then the value in the default is used
%
%   free           Array of ones and zeros that indicates which parameters are to be refined:
%                     - 1 to refine the corresponding parameter
%                     - 0 to fix the corresponding parameter
%                   If empty or omitted then all parameters are free
%
%
% Output:
% -------
%   mod_opts        Structure with moderator refinement options - all fields
%                  will be filled:
%                       pulse_model Name of moderator pulse shape model
%                       pin         Pulse shape parameters (row vector)
%                       free        Logical row vector of zeros and ones
%                   If there is an error, then all fields are set to [];
%
%   ok              True if all OK; false otherwise
%
%   mess            Empty string if OK; error message if not


% Parse the other options
if numel(varargin)<=3
    if numel(varargin)==3
        % Case of all pulse_model, pin, free all being provided - don't need to use default
        mod_opts_in.pulse_model = varargin{1};
        mod_opts_in.pin = varargin{2};
        mod_opts_in.free = varargin{3};
        [mod_opts,ok,mess] = check_ok (mod_opts_in);
        
    else
        [mod_opts,ok,mess] = check_ok (mod_opts_default);   % Check defaults
        if ok
            if numel(varargin)==1
                mod_opts_in.pulse_model = mod_opts_default.pulse_shape;
                mod_opts_in.pin = mod_opts_default.pin;
                mod_opts_in.free = varargin{1};
                [mod_opts,ok,mess] = check_ok (mod_opts_in);
            elseif numel(varargin)==2
                mod_opts_in.pulse_model = mod_opts_default.pulse_shape;
                mod_opts_in.pin = varargin{1};
                mod_opts_in.free = varargin{2};
                [mod_opts,ok,mess] = check_ok (mod_opts_in);
            end
        else
            [mod_opts,ok] = check_ok;
            mess = 'Default moderator pulse model is not valid';
        end
    end
else
    [mod_opts,ok] = check_ok;
    mess = 'Check the number of input argument(s)';
end


%--------------------------------------------------------------------------------------------------
function [mod_opts,ok,mess] = check_ok (mod_opts_in)
% Check validity of moderator options structure, setting defaults for empty fields where possible
%
%   >> [mod_opts,ok,mess] = check_ok (mod_opts_in)
%
% If not valid (or no input argument), then returns a 1x1 structure with the fields
% all set to []


names={'pulse_model';'pin';'free'};     % valid names

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

% Check structure is scalar
% -------------------------
if ~isscalar(mod_opts_in)
    mod_opts=empty_struct(names);
    ok=false; mess='Moderator refinement options structure must be scalar'; return
end

% Check input
% -----------
mod_opts=mod_opts_in;

% Check name
if isempty(mod_opts.pulse_model) || ~is_string(mod_opts.pulse_model)
    mod_opts=empty_struct(names);
    ok=false; mess='Moderator pulse shape name must be a character string'; return
end

% Check initial parameter values
if ~isempty(mod_opts.pin) && isnumeric(mod_opts.pin)
    mod_opts.pin=mod_opts.pin(:)';
else
    mod_opts=empty_struct(names);
    ok=false; mess='Initial moderator pulse shape parameters must be a numeric row vector'; return
end

% Check free parameters
if islognum(mod_opts.free)
    mod_opts.free = logical(mod_opts.free(:))';
else
    mod_opts=empty_struct(names);
    ok=false; mess='The free/fixed parameter list for refinement must be a logical row vector'; return
end

% Check number of parmaeters in initial values and fix/free lists
if numel(mod_opts.pin)~=numel(mod_opts.free)
    mod_opts=empty_struct(names);
    ok=false; mess='The number of moderator pulse shape parameters for refinement is inconsistent with the fixed/free parameter list'; return
end

% Check the moderator model is recognised by the pulse_shape method
try
    dummy_mod=IX_moderator;
    dummy_mod.pulse_model=mod_opts.pulse_model;
    dummy_mod.pp=mod_opts.pin;
    dummy_mod.energy=10;    % because energy = 0 may be invalid, choose some reasonable value
    dummy_val=pulse_shape(dummy_mod,0);    % evaluate at t=0 to test all is OK
catch
    mod_opts=empty_struct(names);
    ok=false; mess='The moderator pulse shape model for refinement is not recognised or the initial parameter value array is not valid'; return
end

% OK if got to here
ok=true;
mess='';

%--------------------------------------------------------------------------------------------------
function s=empty_struct(names)
% Create scalar structure with input fields and all values set to []
args=[names(:)';repmat({[]},1,numel(names))];
s=struct(args{:});
