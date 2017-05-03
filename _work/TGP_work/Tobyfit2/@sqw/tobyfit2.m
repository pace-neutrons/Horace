function mf_object = tobyfit2 (varargin)
% Simultaneously fits resolution broadened S(Q,w) models to sqw objects.
% Allows for optional background functions.
%
% For a direct geometry Fermi chopper instrument:
%   >> myobj = tobyfit2 (w1, w2, ...)      % w1, w2 arrays of objects
%
% More generally:
%   >> myobj = tobyfit2 (w1, w2, ..., instrument_type)
%
%   where instrument_type can be:
%       'fermi'     Direct geometry fermi chopper instrument e.g. MAPS, MERLIN
%       'disk'      Direct geometry disk chopper instrument e.g. LET
%
% This creates a fitting object of class mfclass_Tobyfit with the provided
% data, which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_Tobyfit');">Click here</a>
%
% This method fits model(s) for S(Q,w) as the foreground function(s), and
% function(s) of the plot axes as the background function(s)
%
% For the format of foreground fit functions:
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
%
% The format of the background fit functions depends on the mnumber of plot
% axes for each sqw object. For examples:
% <a href="matlab:doc('example_1d_function');">Click here</a> (1D example)
% <a href="matlab:doc('example_2d_function');">Click here</a> (2D example)
% <a href="matlab:doc('example_3d_function');">Click here</a> (3D example)


% Get resolution function model type
if numel(varargin)>1 && ischar(varargin{end})
    valid_models = {'fermi','disk'};
    ind = strncmpi(varargin{end},valid_models,length(varargin{end}));
    if ~isempty(ind)
        model=valid_models{ind};
    else
        error('Invalid resolution function model type')
    end
    narg=numel(varargin)-1;
else
    model='fermi';
    narg=numel(varargin);
end

% Initialise
if strcmp(model,'fermi')
    mf_init = mfclass_wrapfun (@tobyfit_DGfermi_resconv, [], @func_eval, [],...
        true, false, @tobyfit_DGfermi_resconv_init, []);
elseif strcmp(model,'disk')
    mf_init = mfclass_wrapfun (@tobyfit_DGdisk_resconv, [], @func_eval, [],...
        true, false, @tobyfit_DGdisk_resconv_init, []);
else
    error('Logic error. See Toby Perring.')
end

% Construct
mf_object = mfclass_tobyfit (varargin{1:narg}, 'sqw', mf_init);
