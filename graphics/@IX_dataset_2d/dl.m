function [fig_handle, axes_handle, plot_handle] = dl(w,varargin)
% Draws a line plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> dl(w)
%   >> dl(w,xlo,xhi)
%   >> dl(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dl(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dl(w,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_]=dl(IX_dataset_1d(w),varargin{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
