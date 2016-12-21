function obj = set_refine_moderator (obj, varargin)
% Set the options for refining moderator parameters
%
% No refinement of the moderator
%   >> obj = obj.set_refine_moderator (false)
%
% Refine using current moderator lineshape and parameters as initial values:
%   >> obj = obj.set_refine_moderator
%   >> obj = obj.set_refine_moderator (true)
%
% Set which parameters to refine with a logical array of zeros and ones
%   >> obj = obj.set_refine_moderator (free)
%
% Set pulse shape model parameters different to those in the sqw objects:
% - New initial parameters:
%   >> obj = obj.set_refine_moderator (pin, free)
%
% - New model and initial parameters:
%   >> obj = obj.set_refine_moderator (pulse_model, pin, free)
%
% Alternatively, set the pulse shape, parameters and free parameters using
% the refine moderator options as previously set:
%   >> mod_opts = obj.refine_moderator;
%           :
%   >> obj = obj.refine_moderator (mod_opts)
%
%
% Input parameters in full:
% -------------------------
%   pulse_model     Name of moderator pulse shape model
%                   If empty e.g. [] or '' or omitted then current value in
%                  sqw objects is used (default)
%
%   pin             Initial pulse shape parameters
%                   If empty or omitted then current values in sqw objects
%                  are used
%
%   free            Array of ones and zeros that indicates which parameters
%                  are to be refined:
%                     - 1 to refine the corresponding parameter
%                     - 0 to fix the corresponding parameter
%                   If empty or omitted then all parameters are free
%
%
% EXAMPLES
%   Refine all parameters in the moderator model in the sqw object(s):
%   >> obj = obj.set_refine_moderator
%
%   Specify a model and parameters:
%   >> tauf=5; taus=25; R=0.3;
%   >> obj = obj.set_refine_moderator ('ikcarp',[tauf,taus,R])
%
%   ...allowing only tauf to vary:
%   >> tauf=5; taus=25; R=0.3;
%   >> obj = obj.set_refine_moderator ('ikcarp',[tauf,taus,R],[1,0,0])


if numel(varargin)==1 && islognumscalar(varargin{1}) && ~logical(varargin{1})
    obj.refine_moderator_ = [];
else
    if isempty(obj.refine_crystal_)
        % -------------------------------------------------------------------------------
        % Check there is data
        data = obj.data;
        if ~isempty(data)
            wsqw = cell2mat_obj(cellfun(@(x)x(:),data,'UniformOutput',false));
        else
            error('No data sets have been set - not possible to set moderator refinement options')
        end
        % Check all incident energies are the same in input objects
        [~,~,ok,mess] = get_efix(wsqw);
        if ~ok
            mess=['Moderator refinement: ',mess];
            error(mess)
        end
        % Check that there is a moderator to refine in the data
        [pulse_model,pin,ok,mess,~,present] = get_mod_pulse(wsqw);
        if present
            if ~isempty(pulse_model) && ~ok    % all spe files have same moderator model, but a spread of parameter values
                warning (['Moderator refinement: ',mess])   % warning if too much parameter variation
            end
            mod_opts_default.pulse_model = pulse_model;
            mod_opts_default.pin = pin;
            mod_opts_default.free = true(size(pin));
        else
            error(['Moderator refinement: ',mess])
        end
        % Fill mod_opts, checking for consistency of any supplied information with the current moderator
        if numel(varargin)==0 || (numel(varargin)==1 &&...
                (isempty(varargin{1}) || (islognumscalar(varargin{1}) && logical(varargin{1}))))
            if ~isempty(pulse_model)    % by construction default should be a valid model
                [mod_opts,ok,mess] = refine_moderator_parse (mod_opts_default);
            else
                error(['Moderator refinement: ',mess])
            end
        else
            if numel(varargin)==1 && isstruct(varargin{1})
                [mod_opts,ok,mess] = refine_moderator_parse (varargin{1});
            else
                [mod_opts,ok,mess] = refine_moderator_parse (mod_opts_default,varargin{:});
            end
        end
        if ok
            obj.refine_moderator_ = mod_opts;
        else
            error(mess)
        end
        % -------------------------------------------------------------------------------
    else
        error('Cannot set refine_moderator if refine_crystal has been set')
    end
end
