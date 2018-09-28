function p=make_const_bin_boundaries(pbin,range,pref,inside)
% Make constant interval bin boundaries
%
% Required input:
% ---------------
%   pbin    Binning argument: [plo, pstep, phi].
%
%           If pstep>0: defines bin centres and bin size
%               If plo and phi both finite, then bin centre alignment is to plo, and phi is 
%                   interpreted as the data limit to be included in the bins
%               If plo=-Inf, then bin centre alignment is to phi, and lowest bin boundary
%                   set to include lowest data point given by min(range) (below)
%               If phi=+Inf, then bin centre alignment is to plo, and highest bin boundary
%                   set to include highest data point given by max(range) (below)
%               If plo=-Inf and phi=+Inf, then bin centre alignment is to zero, and
%                   lower and upper bin boundaries set to include range of data set by range (below).
%
%           If pstep=0: bin size and alignment will be determined from optional input argument
%               pref (below), and plo, phi will be interpreted as ranges of data to be covered by bins.
%               If either plo=-Inf or phi=+Inf, then corresponding range will be taken from range (below).
%           
% Optional input:
% ---------------
%   range   Range of data to be covered by bins.
%            - can be simply the lower and upper data ranges: [range_lo, range,hi]
%            - more generally, array of data points, assumed to be in increasing order
%           Used to set the overall extent of the bin boundaries when the corresponding lower and/or upper
%          limit(s) in pbin are -Inf and/or Inf. (Argument is ignored if lower and upper limits in pbin are
%          finite, so can set to anything in this case)
%
%   pref    Reference bin size and alignment information used when pstep in pbin is zero.
%           If pref scalar: pstep set to pref, bin centres aligned to zero
%                (i.e. pref is bin size)
%           If pref array:  pstep=pref(2)-pref(1), bin boundaries aligned to pref(1).
%                (i.e. pref can be a set of bin boundaries, and the output will be aligned to pref).
%
%   inside  If pstep=0, so that pref was used to determine the binning size and alignment, then
%          if inside=true, only bins whose centres in the range determined by pbin and range will be retained
%          This inverts the interpretation of the range - useful for energy binning arguments.
%
% Ouput:
% ------
%   p       Column vector of bin boundaries


% Check input arguments
% -----------------------
if ~isnumeric(pbin) || numel(pbin)~=3
    error('Binning argument is invalid data type or length')
else
    plo=pbin(1);
    phi=pbin(3);
    pstep=pbin(2);
    if pstep<0 || (~isfinite(plo) && plo~=-Inf) || (~isfinite(phi) && phi~=Inf) || plo>phi
        error('Binning argument values invalid')
    end
end

if exist('range','var') && ~isempty(range)
    range_exist=true;
    if ~isnumeric(range) || isempty(range)
        error('Argument ''range'' must be a numeric array if present')
    end
else
    range_exist=false;
end

if exist('pref','var') && ~isempty(pref)
    pref_exist=true;
    if ~isnumeric(pref)
        error('Argument ''pref'' must be a numeric vector length at least 1 if present')
    end
    if numel(pref)==1
        if pref>0
            pstep_ref=pref;
            p0_ref=pstep_ref/2;
        else
            error('Argument ''pref'' must be >0 if scalar')
        end
    else
        pstep_ref=pref(2)-pref(1);
        p0_ref=pref(1);
    end
else
    pref_exist=false;
end

if exist('inside','var') && ~isempty(inside)
    if isnumeric(inside)||islogical(inside) && numel(inside)==1
        inside=logical(inside);
    else
        error('Argument ''inside'' must be logical 0 or 1')
    end
else
    inside=false;
end


% Bin size, bin alignment and data range:
% ---------------------------------------
if pstep>0
    pstep_from_pbin=true;
    if isfinite(plo) && isfinite(phi)
        p0=plo-pstep/2;
        xmin=p0;
        xmax=phi;
    elseif isfinite(plo) && ~isfinite(phi) && range_exist && isfinite(range(end))
        p0=plo-pstep/2;
        xmin=p0;
        xmax=range(end);
    elseif ~isfinite(plo) && isfinite(phi) && range_exist && isfinite(range(1))
        p0=phi+pstep/2;
        xmin=range(1);
        xmax=p0;
    elseif range_exist && isfinite(range(1)) && isfinite(range(end))
        p0=pstep/2;
        xmin=range(1);
        xmax=range(end);
    else
        error('One or more of bin centre positions in ''pbin'' are infinite, but no finite default value given')
    end
else
    pstep_from_pbin=false;
    if pref_exist
        pstep=pstep_ref;
        p0=p0_ref;
    else
        error('Bin size = 0 but no default bin boundary data provided from which to take a default')
    end
    
    if isfinite(plo) && isfinite(phi)
        xmin=plo;
        xmax=phi;
    elseif isfinite(plo) && ~isfinite(phi) && range_exist && isfinite(range(end))
        xmin=plo;
        xmax=range(end);
    elseif ~isfinite(plo) && isfinite(phi) && range_exist && isfinite(range(1))
        xmin=range(1);
        xmax=phi;
    elseif range_exist && isfinite(range(1)) && isfinite(range(end))
        xmin=range(1);
        xmax=range(end);
    else
        error('One or more of data limits in ''pbin'' are infinite, but no finite default value given')
    end
end


% Compute bin boundaries:
% -------------------------
if xmin>xmax
    p=zeros(0,1);   % empty column vector; this will happen if phi=Inf, range_hi<plo, for example
elseif xmin==xmax
    p=[xmin;xmax];  % coincident bin boundaries; can happen if all data at same x value, for example
else
    nlo = floor((xmin-p0)/pstep);
    nhi = ceil((xmax-p0)/pstep);
    p=(p0+pstep*(nlo:nhi))';
    % Had problems with Matlab x1:x2:x3 function with rounding errors, also, calculation  of nlo, nhi involved real arithmetic
    % so to avoid any possibility of rounding problems
    nlo_new=nlo;
    nhi_new=nhi;
    if xmin<p(1); nlo_new=nlo-1; end
    if xmax>p(end); nhi_new=nhi+1; end
    if nlo_new~=nlo || nhi_new~=nhi
        p=(p0+pstep*(nlo_new:nhi_new))';
    end
    if numel(p)==1  % shouldn't happen, but just in case of rounding...
        p=[p;p];
    end
end

% Operate according as 'inside' argument
if ~pstep_from_pbin && inside && ~isempty(p)
    if xmin~=xmax
        pcent=0.5*(p(2:end)+p(1:end-1));
        ind=find((pcent>=xmin & pcent<=xmax));
        if ~isempty(ind)
            ind=[ind;ind(end)+1];
            p=p(ind);
        else
            p=zeros(0,1);
        end
    else
        % this is the special case when lower and upper bin coincide; we want to exclude this
        p=zeros(0,1);
    end
end
