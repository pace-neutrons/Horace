function [fig_handle, axes_handle, plot_handle] = pm(w,varargin)
% Overplot markers for a spectrum or array of spectra on an existing plot
%
%   >> pm(w)
%
% Advanced use:
%   >> pm(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pm(w,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_,ok,mess]=plot_oned (w,varargin{:},'newplot',false,'type','m');
if ~ok
    error(mess)
end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
