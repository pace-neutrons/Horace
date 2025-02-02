function varargout = mplot(w,varargin)
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


varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = da(w, varargin{:});
