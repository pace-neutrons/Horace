function wdist = distribution (w, bounds_in, nbin_in)
% Return the distribution of values in a IX_dataset_1d
%
% The output is a histogram spectrum, expressed as a distribution  i.e. returns
% the number of elements per unit length of the y-axis of the input spectrum.
% Equivalently, it is a 'density of states'.
%
% Syntax:
%   >> wdist = distribution(w)
%
%   >> wdist = distribution(w, range_factor)
%
%   >> wdist = distribution(w, range_factor, nbins)
%
%   >> wdist = distribution(w, range)
%
%   >> wdist = distribution(w, range, nbins)
%
%   >> wdist = distribution(w, bin_boundaries)
%
% Input:
% -------
%   range_factor    Bins cover the range 0 - range_factor*median(w.y)
%                   [Default: range_factor = 4]
%
%   range           Pair of values giving lower and upper limits: [start,finish] 
%
%   nbins           Number of bins the range is split into
%                   [Default: max(number_points_in_range/100, 10) i.e. on average the no.
%                   elements contributing to a bin is 100, with a minimum of 10 bins]
%
%   bin_boundaries  Array of bin boundaries (length at least 3)
%
%
% Output:
% -------
%   wdist           Histogram IX_dataset_1d

% Default values for limits and no. bins over-ridden if input provided
factor_ref = 4; % must be +ve
n_el_av = 100;
nbin_min = 10;

% Check that there are numbers in the input spectrum
if isempty(w.signal(~isnan(w.signal)))
    error ('All elements of spectrum are NaN')
end

if (nargin==1)
    factor = factor_ref;
    ylo = 0;
    yhi = factor*median(w.signal(~isnan(w.signal)));    % remove NaN elements from the calculation of the range
    if (ylo>yhi)
        temp=ylo;
        ylo=yhi;
        yhi=temp;
    end
    ysort = sort(w.signal);
    n_el = length(find(ysort>=ylo & ysort<=yhi));
    nbin = max(n_el/n_el_av,nbin_min);
    bounds = linspace(ylo,yhi,nbin+1);
    
elseif nargin==2
    if length(bounds_in)>2      % bin boundaries explicitly given
        if min(diff(double(bounds_in))) <= 0
            error ('bin boundaries must be strictly monotonically increasing')
        end
        bounds = bounds_in;
    else
        if length(bounds_in)==1     % multiple of median value
            factor = abs(bounds_in);    % in case input argument is -ve
            ylo = 0;
            yhi = factor*median(w.signal(~isnan(w.signal)));    % remove NaN elements from the calculation of the range
        elseif length(bounds_in)==2
            ylo = bounds_in(1);
            yhi = bounds_in(2);
        end
        if (ylo>yhi)
            temp=ylo;
            ylo=yhi;
            yhi=temp;
        end
        ysort = sort(w.signal);
        n_el = length(find(ysort>=ylo & ysort<=yhi));
        nbin = max(n_el/n_el_av,nbin_min);
        bounds = linspace(ylo,yhi,nbin+1);
    end
    
elseif nargin==3
    if length(bounds_in)==1     % multiple of median value
        factor = abs(bounds_in);    % in case input argument is -ve
        ylo = 0;
        yhi = factor*median(w.signal(~isnan(w.signal)));    % remove NaN elements from the calculation of the range
    elseif length(bounds_in)==2
        ylo = bounds_in(1);
        yhi = bounds_in(2);
    else
        error ('Second argument must be [ylo,yhi] or range_factor')
    end
    if (ylo>yhi)
        temp=ylo;
        ylo=yhi;
        yhi=temp;
    end
    if length(nbin_in)==1
        if nbin_in >= 1
            bounds = linspace(ylo,yhi,nbin_in+1);
        else
            error ('Number of bins must be > 0')
        end
    else
        error ('Check type or length of nbin')
    end
    
else
    error ('Too many arguments')
end

% Calculate the distribution
n=histc(w.signal',bounds);
n(end-1)=n(end-1)+n(end);    % add the number of points that lie on the edge of the last boundary to the penultimate bin
n = n(1:end-1)./diff(bounds);
e=zeros(size(n));
wdist = spectrum (bounds,n,e,'Distribution','y-value','Number of elements','unit y',1);
