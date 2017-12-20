function varargout = multifit (varargin)
% Simultaneously fit function(s) to one or more IX_dataset_3d objects
%
%   >> myobj = multifit (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_IX_dataset_3d with the provided
% data, which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:help('mfclass_IX_dataset_3d');">Click here</a>
%
% For the format of fit functions (foreground or background), see the example:
% <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
%
%[Help for legacy use (2017 and earlier):
%   If you are still using the legacy version then it is strongly recommended
%   that you change to the new operation. Help for the legacy operation can
%   be <a href="matlab:help('IX_dataset_3d/multifit_legacy');">found here</a>]


if ~mfclass.legacy(varargin{:})
    mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
    varargout{1} = mfclass_IX_dataset_3d (varargin{:}, 'IX_dataset_3d', mf_init);
else
    varargout = mfclass.legacy_call (@multifit_legacy, nargout, varargin{:});
end
