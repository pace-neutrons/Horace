function [fig_handle, axes_handle, plot_handle] = mplot(w,varargin)
% Draw an area plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> mplot(w)
%   >> mplot(w,xlo,xhi)
%   >> mplot(w,xlo,xhi,ylo,yhi)
%   >> mplot(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> mplot(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = mplot(w,...) 
%
%
% Synonym for:
%   >> da(...)

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_] = da(w, varargin{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
