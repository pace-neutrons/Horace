function varargout = samp2distr(xsamp,varargin)
% Create an IX_dataset_1d of a pdf from an array of sampled values
%
%   >> samp2distr(xsamp)        % plot distribution
%   >> samp2distr(xsamp,nbins)  % with specified number of bins
%   >> samp2distr(xsamp,edges)  % with particular bin boundaries
%
%   >> w = samp2distr(xsamp)    % return distribution without plotting


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
