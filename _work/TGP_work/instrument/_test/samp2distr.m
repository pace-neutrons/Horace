function varargout = samp2distr(xsamp,varargin)
% Create an IX_dataset_1d of a pdf from an array of sampled values
%
%   >> samp2distr(xsamp)        % plot distribution
%   >> w = samp2distr(xsamp)    % return distribution without plotting

% % Parse arguments
% opt = {'plot'};
% flags = {'plot'};
% [par,opt] = parse_arguments (varargin, opt, flags);

[N,edges] = histcounts(xsamp(:),varargin{:});
w = IX_dataset_1d(edges,N,sqrt(N));
area=integrate(w);
w = w/area.val;

if nargout>0
    varargout{1}=w;
end

if nargout==0
    dh(w)
    xlo = min(xsamp(:));
    xhi = max(xsamp(:));
    dx=xhi-xlo;
    xlims = [xlo-dx/10,xhi+dx/10];
    ylims = [0,1.1*max(w.signal)];
    lx(xlims);
    ly(ylims)
end
