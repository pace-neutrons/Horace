function warr = mspec_core (ns, s, msk, detpar, av_mode, unit, binning)
% Core function used to create array of tofspectra from spectrum-to-workspace mapping, with a mask file
%   >> warr = mspec (ns, s [,msk] [,av_mode])
%
%   ns      Array of number of spectra in each workspace (before any masking)
%           (note: elements of ns can be equal to zero)
%
%   s       Array containing list of spectra in order of increasing workspace number
%           (note: it is required that there are no repeated spectra)
%           (note: sum of elements of ns must be equal to the length of s)
%
%   msk     Array of spectra to be masked
%
%   detpar  Structure obtained from previous read of detector.dat
%
%   av_mode Averaging scheme (default is 'average')
%               = 'average'         take the average for all detector elements in a workspace
%               = 'min_twotheta'    take parameters from the detector element with minimum twotheta
%               = 'max_twotheta'    take parameters from the detector element with minimum twotheta
%               = 'none'            dummy call - no parameters calculated, and w is returned as a double
%                                   with value zero.
%   unit    Character code giving units e.g.
%           't', 'd', 'lam', 'w', 'thz'
%           (type help tofspectrum/units for full set)
%
%   binning Parameters that define the rebinning of the workspaces
%              e.g.  [xlo,xhi] or [xlo,dx,xhi]  (see >> help rebin for details)
%           Can give different parameters for each workspace as a cell array of binning parameters,
%           one cell per workspace.
%

x1=get_primary;
[efix,emode]=get_efix;

% -----------------------------------------------------------------------------------------------
% Read workspace-spectrum mapping  and prepare lists of spectra, workspaces for reading in data
% -----------------------------------------------------------------------------------------------
ntc = double(genie_get('ntc1'));
nsp = double(genie_get('nsp1'));
nper= double(genie_get('nper'));
nsptot = nper*(nsp+1) - 1;    % maximum spectrum number in a multi-period run


% Check input data have correct type and dimensions
% ----------------------------------------------------
if numel(size(ns))~=2 || size(ns,1)~=1
    error ('Number of spectra in each workspace must be 1D row vector')
end

if numel(size(s))~=2 || size(s,1)~=1
    error ('List of spectra in workspaces must be 1D row vector')
end

if numel(s)~=sum(ns)
    error ('Sum of spectra per workspace and spectrum list inconsistent in mapping information')
end

if numel(ns)<1
    error('Must have at least one workspace')
end

if ~isempty(msk)
    if numel(size(msk))~=2 || size(msk,1)~=1
        error ('List of masked spectra must be 1D row vector')
    end
end

if ~isempty(binning)
    nw=numel(ns);
    bin=true;
    if isnumeric(binning)
        if size(binning,1)==1
            binpar=repmat({binning},nw,1);
        elseif size(binning,1)==nw
            binpar=mat2cell(binning,ones(1,nw),size(binning,2));
        else
            error('Check size of array of binning parameters - must be a single description, or one per workspace')
        end
    elseif iscell(binning)
        if numel(binning)==1
            binpar=repmat(binning,nw,1);
        elseif numel(binning)==nw
            binpar=binning(:);
        else
            error('Check size of cell array of binning parameters - must be a single description, or one per workspace')
        end
    else
        error('Check rebinning description')
    end
else
    bin=false;
end

% Get no. spectra per workspace, sorted list of spectra and list of workspace numbers for each spectra
% ----------------------------------------------------------------------------------------------------
% (arrays: ns_msk, w_msk, sp_msk; ns_msk may contain zeros)

% Sort the spectra into increasing spectrum number, and check validity of elements
[sp,iarr]=sort(s);
if sp(1)<0 || sp(end)>nsptot
    error (['Spectrum numbers in mapping must lie between 0 and ',num2str(nsptot)])
end
if numel(sp)>2 && any(diff(sp)==0)
    error ('A spectrum must appear in only one workspace')
end

% Create array of indices to workspaces corresponding to the sorted spectrum list
nw=numel(ns);
w=ones(1,numel(s));
nscum=cumsum(ns);
for i=2:nw
    w(nscum(i-1)+1:nscum(i))=i;
end
w = w(iarr);

% Create array of masked spectra, containing only unique entries
if ~isempty(msk)
    if ~issorted(msk) || any(diff(msk)==0)
        msk_sort = unique(msk);
    else
        msk_sort = msk;
    end
    % Use trick to speed up case when large mask list, but only a few spectra in sp
    ilo = lower_index(msk_sort,sp(1));   % get range of indices that correspond to the spectra in the map file
    ihi = upper_index(msk_sort,sp(end));
    if ihi>=ilo
        msk_short = msk_sort(ilo:ihi);
    else
        msk_short = [];
    end
else
    msk_short = [];
end

% Combine information from mapping file and mask file to get a list of spectra that must be read
%   [fortran-style loop would probably be faster in a high level language, but very slow in old versions of MATLAB]
if ~isempty(msk_short)
    sp2w = zeros(1,sp(end)-sp(1)+1);    % mask array, whose non-zero elements will be spectra to keep (offset by sp(1)-1)
    sp2w(sp-(sp(1)-1))=w;               % indicate which spectra to keep (offset by sp(1)-1), by giving their workspace number
    sp2w(msk_short-(sp(1)-1))=0;        % remove those that are masked
    sp_msk = find(sp2w>0)+(sp(1)-1);    % update this list of spectrum numbers that must be read
    w_msk = sp2w(sp2w>0);               % and the corresponding workspace numbers
    if ~(numel(sp_msk)>0)               % no spectra left after masking
        error ('All spectra in the spectrum-to-workspace mapping are masked')
    end
    % Get the number of spectra in the workspaces now that masked spectra have been removed
    ns_msk = zeros(1,nw);
    [wsort,ix] = sort(w_msk);
    s_msk=sp_msk(ix);                   % spectra in order of workspace number
    iwsort = find([1,diff(wsort)]>0);   % indices of first occurence in wsort of each workspace number
    ns_msk(wsort(iwsort))=diff([iwsort,length(w_msk)+1]);   % number of spectra in each workspace after masking
else
    s_msk  = s;
    sp_msk = sp;
    w_msk  = w;
    ns_msk = ns;
end


% Get workspace parameters, ans spectrum parameters if units change required
% ---------------------------------------------------------------------------
% Will use parameters for masked workspaces, unless all spectra have been masked, in which case use unmasked workspace parameters

[delta, twotheta, azimuth, x2] = get_workspace_par (detpar, s_msk, ns_msk, av_mode);

w_empty=(ns_msk==0);
if any(w_empty)
    map=mat2cell(s,1,ns);
    [delta(w_empty), twotheta(w_empty), azimuth(w_empty), x2(w_empty)] = get_workspace_par (detpar, map(w_empty), av_mode);
end


% -----------------------------------------------------------------------------------------------------------------------
% Read in blocks of spectra, accumulate sums for the workspaces, changing units if necessary
% -----------------------------------------------------------------------------------------------------------------------

% Read in the counts
[is_lo,is_hi,sp_lo,sp_hi] = get_read_spectra_blocks (sp_msk);   % Get lower and upper limits for reading blocks of spectra

if strcmpi(unit,'t')
    % Accumulate counts for the workspaces
    wcnt = zeros(ntc,nw);   % array in which to accumulate counts for the workspaces
    for i=1:numel(sp_lo)
        cmd = strcat('cnt1[',num2str(sp_lo(i)),':',num2str(sp_hi(i)),']');
        cnt = double(gget(cmd));
        for j=is_lo(i):is_hi(i) % loop over indices of spectra to be read. Must be a loop, as more than one spectrum may go into one workspace
            wcnt(:,w_msk(j)) = wcnt(:,w_msk(j)) + cnt(2:ntc+1,sp_msk(j)-(sp_msk(is_lo(i))-1));
        end
    end
    % Make mgenie spectra
    conv=1./gget('dtchan1')';    % inverse of time channels (so multiply later on, not divide)
    wx = gget('tchan1')';
    wy = wcnt(:,1).*conv;
    we = sqrt(wcnt(:,1)).*conv;
    wtitle = avoidtex(genie_get);  % inquire about genie source
    [ok,xlab,xunit] = units_to_caption ('t',0); % get captions for time-of-flight
    wsp = IX_dataset_2d(wtitle,wy,we,IX_axis('Counts'),wx,IX_axis(xlab,xunit),true,1,IX_axis('Workspace index'),false);
    par = tofpar(emode,delta(1),x1,x2(1),twotheta(1),azimuth(1),efix);
    if nw>1
        warr = repmat(tofspectrum(wsp,par,'t'),1,nw); % repeat workspace to preallocate (and therefore save CPU time)
        for iw=2:nw
            wy = wcnt(:,iw).*conv;
            we = sqrt(wcnt(:,iw)).*conv;
            warr(iw)=set_simple_yse_detpar(warr(iw),iw,wy,we,delta(iw),x2(iw),twotheta(iw),azimuth(iw));
        end
        if bin
            for i=1:nw
                warr(i)=rebin(warr(i),binpar{i});
            end
        end
    else    % only one workspace to be returned
        warr = tofspectrum(wsp,par,'t');
        if bin
            warr=rebin(warr,binpar{1});
        end
    end
    
else
    % Create dummy tofspectrum to be used as basis for rebinning and units conversion
    wx = gget('tchan1')';
    wy=zeros(numel(wx)-1,1);
    we=zeros(numel(wx)-1,1);
    wtitle = avoidtex(genie_get);  % inquire about genie source
    [ok,xlab,xunit] = units_to_caption ('t',0); % get captions for time-of-flight
    wsp = IX_dataset_2d(wtitle,wy,we,IX_axis('Counts'),wx,IX_axis(xlab,xunit),true,1,IX_axis('Workspace index'),false);
    par=tofpar(emode,0,x1,0,0,0,efix);
    wtof=tofspectrum(wsp,par,'t');
    
    % Create the output tofspectra
    warr=tofspectrum;
    wfilled=false(1,nw);
    if nw>1
        warr=repmat(warr,1,nw);
    end
    
    % Get spectrum parameters
    [delta_s, twotheta_s, azimuth_s, x2_s] = get_workspace_par (detpar, sp_msk, av_mode);
    
    conv=1./gget('dtchan1')';    % inverse of time channels (so multiply later on, not divide)
    for i=1:numel(sp_lo)
        cmd = strcat('cnt1[',num2str(sp_lo(i)),':',num2str(sp_hi(i)),']');
        cnt = double(gget(cmd));
        for j=is_lo(i):is_hi(i) % loop over indices of spectra to be read. Must be a loop, as more than one spectrum may go into one workspace
            wy=cnt(2:ntc+1,sp_msk(j)-(sp_msk(is_lo(i))-1)).*conv;
            we=sqrt(wy.*conv);
            wtof=set_simple_yse_detpar(wtof,wy,we,delta_s(j),x2_s(j),twotheta_s(j),azimuth_s(j));
            wunits=units(wtof,unit);
            if wfilled(w_msk(j))
                if bin
                    warr(w_msk(j))=warr(w_msk(j))+rebin(wunits,binpar{w_msk(j)});
                else
                    warr(w_msk(j))=warr(w_msk(j))+rebin(wunits,warr(w_msk(j)));
                end
            else
                if bin
                    warr(w_msk(j))=rebin(wunits,binpar{w_msk(j)});
                else
                    warr(w_msk(j))=wunits;
                end
                wfilled(w_msk(j))=true;
            end
        end
    end

end

%========================================================================================================================
function [is_lo,is_hi,sp_lo,sp_hi] = get_read_spectra_blocks (speclist)
% Find nearly contiguous blocks of spectra in a sorted list
%
%   >> [is_lo,is_hi,sp_lo,sp_hi] = get_read_spectra_blocks (speclist, max_break)
%
%   speclist    Sorted list of spectra
%   max_break   Maximum break in continuous list that is tolerated within one block
%
%   is_lo, is_hi    Indicies of lower and upper bounds in the array speclist
%   sp_lo, sp_hi    Actual spectrum numbers


ntc = double(gget('ntc1'));

% Determine control parameters
% -------------------------------
%   - max number of spectra to read in a single block
%   - the threshold number of adjacent masked spectra that determines a new block of spectra is to be read
%   - small number to use to avoid rounding errors
t_block     = 1e4;          % overhead time (microseconds) for a single call to gget('cnt[i:j]')
t_datapoint = 0.2;          % time (microseconds) to read a single data point in gget('cnt[i:j]')
max_points  = 1048576;      % buffer size of data points
max_sp = max(1,floor(max_points/ntc));
max_msk= max(1,floor((max_sp*t_block)/(t_datapoint*max_points)));
max_sp = max(1,2^round(log2(max_sp)));  % round max_sp to nearest power of two
del_sp = 0.01/max_sp;                   % used to avoid any rounding errors from double precision arithmetic (may not be necessary)

if length(speclist)~=1    % more than one spectrum
    % find spectrum indices after which there is a break of more than max_msk spectra; prepend 0 for convenience later on
    brk = [0,find(diff(speclist)>max_msk), length(speclist)];
    temp = zeros(1,length(speclist));
    % create a logical array containing indices of spectra that form end of a block to be read
    % blocks will terminate at positions of breaks determined above
    for ib=1:length(brk)-1
        temp(brk(ib)+1:brk(ib+1)) = [diff(floor((speclist(brk(ib)+1:brk(ib+1))-speclist(brk(ib)+1)+del_sp)./max_sp)),1];
    end
    % create arrays of lower and upper bounds of the blocks of spectra
    is_lo = find([1,temp(1:end-1)]>0);   % index of lower bounds in the array speclist
    is_hi = find(temp>0);
    sp_lo = speclist(is_lo);                   % actual spectrum numbers of lower bounds
    sp_hi = speclist(is_hi);
else
    is_lo = 1;
    is_hi = 1;
    sp_lo = speclist;
    sp_hi = speclist;
end
