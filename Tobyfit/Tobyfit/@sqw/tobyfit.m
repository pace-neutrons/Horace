function varargout = tobyfit (varargin)
% Simultaneously fits resolution broadened S(Q,w) models to sqw objects.
%
% For a direct geometry Fermi chopper instrument:
%   >> myobj = tobyfit (w1, w2, ...)      % w1, w2 sqw objects or arrays of objects
%
% More generally:
%   >> myobj = tobyfit (w1, w2, ..., instrument_type)
%
%   where instrument_type can be:
%       'fermi'     Direct geometry fermi chopper instrument e.g. MAPS, MERLIN
%       'disk'      Direct geometry disk chopper instrument e.g. LET
%
% This creates a fitting object of class mfclass_Tobyfit with the provided
% data, which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details on how to do this <a href="matlab:help('mfclass_Tobyfit');">Click here</a>
%
% Tobyfit fits model(s) for S(Q,w) as the foreground function(s), and
% function(s) of the plot axes as the background function(s)
%
% For the format of foreground fit functions see the following examples:
% <a href="matlab:edit('example_sqw_spin_waves');">Damped spin waves</a>
% <a href="matlab:edit('example_sqw_flat_mode');">Dispersionless excitations</a>
%
% The format of the background fit functions depends on the number of plot
% axes for each sqw object. For examples see:
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
% <a href="matlab:edit('example_2d_function');">example_2d_function</a>
% <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
%
%
%[Help for legacy use (2017 and earlier):
%   If you are still using the legacy version then it is strongly recommended
%   that you change to the new operation. Help for the legacy operation can
%   be <a href="matlab:help('sqw/tobyfit_legacy');">found here</a>]


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if ~mfclass.legacy(varargin{:})
    % ------------------------------------------------------------------------------
    % Tobyfit (1 Jan 2018 onwards)
    % ----------------------------
    % Get resolution function model type
    if numel(varargin)>1 && ischar(varargin{end})
        valid_models = {'fermi','disk','gst'};
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
    elseif strcmp(model,'gst')
%         mf_init = mfclass_wrapfun (@tobyfit_DGfermi_res_points, [], @func_eval, [],...
%             true, false, @tobyfit_DGfermi_resconv_init, []);
        mf_init = mfclass_wrapfun (@gst_DGfermi_resconv, [], @func_eval, [],...
            true, false, @tobyfit_DGfermi_resconv_init, []);
    elseif strcmp(model,'disk')
        mf_init = mfclass_wrapfun (@tobyfit_DGdisk_resconv, [], @func_eval, [],...
            true, false, @tobyfit_DGdisk_resconv_init, []);
    else
        error('Logic error. See Toby Perring.')
    end
    
    % Construct
    varargout{1} = mfclass_tobyfit (varargin{1:narg}, 'sqw', mf_init);
    
    % ------------------------------------------------------------------------------
    
else
    % Legacy Tobyfit (until 31 Dec 2017)
    % ----------------------------------
    [varargout{1:nargout}] = mfclass.legacy_call (@tobyfit_legacy, varargin{:});
end
