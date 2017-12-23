function [wout, fitdata, ok, mess] = fit(win, varargin)
% *** Deprecated function ***
%   This function is no longer maintained. It is strongly recommended
%   that you use multifit instead. For more information about multifit
%   <a href="matlab:help('IX_data_3d/multifit');">click here</a>.
%
%   Help for the legacy operation can be <a href="matlab:help('IX_data_3d/fit_legacy');">found here</a>]


[wout,fitdata,ok,mess] = fit_legacy(win, varargin{:});
