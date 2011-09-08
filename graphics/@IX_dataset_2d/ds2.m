function [fig_handle, axes_handle, plot_handle] = ds2(w,varargin)
% Draw a surface plot of an IX_dataset_2d or array of IX_dataset_2d, with error bars as colour
%
%   >> ds2(w)
%   >> ds2(w,xlo,xhi)
%   >> ds2(w,xlo,xhi,ylo,yhi)
%   >> ds2(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Differs from ds in that the signal sets the z axis, and the colouring is 
% set by the error bars. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectrl weight).
%
% Advanced use:
%   >> ds2(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ds2(w,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_,ok,mess]=plot_twod (w,varargin{:},'newplot',true,'type','surface2');
if ~ok
    error(mess)
end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
