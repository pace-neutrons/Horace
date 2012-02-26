function [fig_handle, axes_handle, plot_handle] = ph(w,varargin)
% Overplot histogram for an IX_dataset_2d or array of IX_dataset_2d on an existing plot
%
%   >> ph(w)
%
% Advanced use:
%   >> ph(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ph(w,...) 

% Check input arguments
[ok,mess]=parse_args_simple_ok_syntax({'name'},varargin{:});
if ~ok
    error(mess)
end

% Perform plot
[fig_,axes_,plot_]=ph(IX_dataset_1d(w),varargin{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
