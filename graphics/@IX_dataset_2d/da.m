function [fig_handle, axes_handle, plot_handle] = da(w,varargin)
% Draws a histogram plot of a spectrum or array of spectra
%
%   >> da(w)
%   >> da(w,xlo,xhi)
%   >> da(w,xlo,xhi,ylo,yhi)
%   >> da(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> da(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dh(a,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_,ok,mess]=plot_twod (w,varargin{:},'newplot',true,'type','area');
if ~ok
    error(mess)
end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
