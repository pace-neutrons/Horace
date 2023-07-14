function obj = tobyfit (varargin)
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
% This creates a fitting object of class mfclass_tobyfit with the provided
% data, which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details on how to do this <a href="matlab:help('mfclass_tobyfit');">Click here</a>
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


% Original author: T.G.Perring

% ------------------------------------------------------------------------------
% Tobyfit (1 Jan 2018 onwards)
% ----------------------------
% Get resolution function model type

% Determine the instrument model
% There must be at least one sqw object in the argument list or this method
% would not have been called. However, it may not be the leading argument.
% We demand that the leading argument is an sqw object.
% The input could be any number of sqw object arrays, followed by other arguments
% hence the slightly involved procedure

is_sqw_object = cellfun(@(x) isa(x,'sqw'), varargin);
ind = find(~is_sqw_object,1);

if isempty(ind)
    nsqw = numel(varargin);
    sqws = varargin;
    argi = {};
else
    nsqw = ind-1;
    sqws = varargin(1:nsqw);
    argi = varargin(nsqw+1:end);
end

if isempty(sqws)
    error('HORACE:tobyfit:invalid_argument', 'There must be at least one leading sqw object in the input argument list to Tobyfit')
end

[inst, all_inst] = get_inst_class(sqws{:});

if isempty(inst)
    if all_inst
        error('HORACE:tobyfit:invalid_argument', 'The instrument type must be the same for all datasets')
    else
        error('HORACE:tobyfit:invalid_argument', 'All sqw objects must now have the instrument type set as an instrument object')
    end
end

% For not actually failing with old syntax where the instrument type was set
% by a character string
if ~isempty(argi) && ischar(argi{end})
    warning('HORACE:tobyfit:deprecated_argument', ...
            'The instrument is determined from the sqw object. Redundant option ''%s'' ignored', argi{end})
end

% Initialise
switch class(inst)
  case 'IX_inst_DGfermi'
    mf_init = mfclass_wrapfun (@tobyfit_DGfermi_resconv, [], @func_eval, [],...
                               true, false, @tobyfit_DGfermi_resconv_init, []);

  case 'IX_inst_DGdisk'
    mf_init = mfclass_wrapfun (@tobyfit_DGdisk_resconv, [], @func_eval, [],...
                               true, false, @tobyfit_DGdisk_resconv_init, []);

  otherwise
    error('HORACE:tobyfit:invalid_argument', 'No resolution function model implemented for this instrument')
end

% Construct
obj = mfclass_tobyfit (sqws{:}, 'sqw', mf_init);

end
