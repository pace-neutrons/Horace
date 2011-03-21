function [fig_handle, axes_handle, plot_handle] = pe(w,varargin)
% Overplot error bars for a spectrum or array of spectra on an existing plot
%
%   >> pe(w)
%
% Advanced use:
%   >> pe(w,'name',fig_name)        % overplot on figure with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pe(w,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_,ok,mess]=plot_oned (w,varargin{:},'newplot',false,'type','e');
if ~ok
    error(mess)
end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
