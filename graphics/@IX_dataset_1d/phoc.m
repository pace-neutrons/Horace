function [fig_handle, axes_handle, plot_handle] = phoc(w)
% Overplot histogram for a spectrum or array of spectra on the current plot
%
%   >> phoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = phoc(w) 

% Check there is a current figure
if isempty(findall(0,'Type','figure'))
    disp('No current figure exists - cannot overplot.')
    return
end

% Perform plot
[fig_,axes_,plot_,ok,mess]=plot_oned (w,'name',gcf,'newplot',false,'type','h');
if ~ok
    error(mess)
end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
