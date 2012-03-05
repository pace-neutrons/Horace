function [w,ytot,etot] = sumspec (varargin)
% Creates a list of integrals for a set of spectra (either a list or range of spectra)
%
%   >> [w,ytot,etot] = sumspec(sp_list)             Integrals over the full time range for spectra in the list
%   >> [w,ytot,etot] = sumspec(sp_list,t_lo,t_hi)   Integrals over the given ranges
%
%   >> [w,ytot,etot] = sumspec(sp_lo,sp_hi)         Integrals over the full time range for a range of spectra
%   >> [w,ytot,etot] = sumspec(sp_lo,sp_hi,t_lo,t_hi)   Integrals over the given ranges
%
% Input:
% ------
%   sp_list     List of spectra over which to integrate (need not be sorted list, but must not contain any repeats)
% *OR*
%   sp_lo,sp_hi Lower and upper limits of a range of spectra (sp_lo <= sp_hi)
%
%   t_lo        Lower integration limits for spectr in the order in sp_list
%              (scalar, or array with number of elements equal to number of spectra)
%
%   t_hi        Upper integration limits
%              (scalar, or array with number of elements equal to number of spectra)
%
% Output:
% -------
%   w           IX_dataset_1d with integrals as a function of increasing spectrum number
%   ytot        Integrated values for the spectra in the order in sp_list
%   etot        Corresponding errors (standard deviation)

% Original routine T.G.Perring


% Get the integration parameters
if nargin>=1 && nargin<=4
    nsptot = double(genie_get('nper'))*(double(genie_get('nsp1'))+1) - 1;    % maximum spectrum number in a multi-period run
    if nargin==1 || nargin==3
        sp_list=varargin{1};
        if any(diff(sp_list)<=0) % not an increasing sorted unique element list
            [sp_list,ind_sp]=sort(sp_list);
            sp_required_sorting=true;
        else
            sp_required_sorting=false;
        end
    else
        if varargin{1}<=varargin{2}
            sp_list=varargin{1}:varargin{2};
            sp_required_sorting=false;
        else
            error('Must have sp_lo <=sp_hi')
        end
    end
    if min(sp_list)<0 || max(sp_list)>nsptot
        error (['Ensure spectrum numbers are in the range 0 - ',num2str(nsptot)])
    end
    nsp=numel(sp_list);
    tchan = gget('tchan1');
    if (nargin<=2)  % integrate over all time channels
        ok=true(nsp,1);
        jlo = ones(nsp,1);
        jhi = double(genie_get('ntc1'))*ones(nsp,1);
        jbeg=zeros(nsp,1);
        jend=zeros(nsp,1);
        frac_beg=zeros(nsp,1);
        frac_end=zeros(nsp,1);
        tlo_char=sprintf('%.3f',tchan(1));
        thi_char=sprintf('%.3f',tchan(end));
    else
        t_lo=varargin{end-1};
        t_hi=varargin{end};
        if isscalar(t_lo) && isscalar(t_hi)
            t_lo=t_lo*ones(nsp,1);
            t_hi=t_hi*ones(nsp,1);
            tlo_char=sprintf('%.3f',t_lo(1));
            thi_char=sprintf('%.3f',t_hi(1));
        elseif ~isscalar(t_lo) && isscalar(t_hi) && numel(t_lo)==nsp
            if sp_required_sorting, t_lo=t_lo(ind_sp); end
            t_lo=t_lo(:);
            t_hi=t_hi*ones(nsp,1);
            t_lo_min=min(t_lo); t_lo_max=max(t_lo);
            if t_lo_min-t_lo_max==0
                tlo_char=sprintf('%.3f',t_lo_min);
            else
                tlo_char='<various>';
            end
            thi_char=sprintf('%.3f',t_hi(1));
        elseif isscalar(t_lo) && ~isscalar(t_hi) && numel(t_hi)==nsp
            t_lo=t_lo*ones(nsp,1);
            if sp_required_sorting, t_hi=t_hi(ind_sp); end
            t_hi=t_hi(:);
            tlo_char=sprintf('%.3f',t_lo(1));
            if t_hi_min-t_hi_max==0
                thi_char=sprintf('%.3f',t_hi_min);
            else
                thi_char='<various>';
            end
        elseif ~isscalar(t_lo) && ~isscalar(t_hi) && numel(t_lo)==nsp && numel(t_hi)==nsp
            if sp_required_sorting, t_lo=t_lo(ind_sp); end
            t_lo=t_lo(:);
            if sp_required_sorting, t_hi=t_hi(ind_sp); end
            t_hi=t_hi(:);
            tlo_char='<various>';
            thi_char='<various>';
        else
            error('Integration limits must be scalar or match the number of spectra')
        end
        [ok,jlo,jhi,jbeg,frac_beg,jend,frac_end]=get_tbin_range(tchan,t_lo,t_hi);
    end
else
    error ('Check number of arguments')
end

% Get integrals
ytot=zeros(1,nsp);
etot=zeros(1,nsp);

[is_lo,is_hi,sp_lo,sp_hi] = get_read_spectra_blocks (sp_list);

nblock = numel(is_lo);
for m=1:nblock
    cmd = strcat('cnt1[',num2str(sp_lo(m)),':',num2str(sp_hi(m)),']');
    cnt = gget(cmd);
    for k=is_lo(m):is_hi(m)
        if ok(k)
            delsp=sp_list(k)-sp_lo(m)+1;
            if jlo(k)~=0
                ytot(k)=sum(double(cnt(jlo(k)+1:jhi(k)+1,delsp)),1);
                etot(k)=ytot(k);
            end
            if jbeg(k)~=0
                ytot(k)=ytot(k)+frac_beg(k)*double(cnt(jbeg(k)+1,delsp));
                etot(k)=etot(k)+(frac_beg(k)^2)*double(cnt(jbeg(k)+1,delsp));
            end
            if jend(k)~=0
                ytot(k)=ytot(k)+frac_end(k)*double(cnt(jend(k)+1,delsp));
                etot(k)=etot(k)+(frac_end(k)^2)*double(cnt(jend(k)+1,delsp));
            end
        end
    end
end
etot=sqrt(etot);

% Fill output spectrum
xvals = (sp_lo(1):sp_hi(end)+1)-0.5;
yvals = NaN(1,sp_hi(end)-sp_lo(1)+1);
evals = NaN(1,sp_hi(end)-sp_lo(1)+1);
yvals(sp_list-sp_lo(1)+1) = ytot;
evals(sp_list-sp_lo(1)+1) = etot;
title = avoidtex(genie_get);
xlab = 'Spectrum number';
ylab = ['Counts from ' tlo_char ' to ' thi_char '\mus'];
distribution = false;
w = IX_dataset_1d(xvals,yvals,evals,title,xlab,ylab,distribution);

% Reorder integrals if necessary
if sp_required_sorting
    ytot(ind_sp)=ytot;
    etot(ind_sp)=etot;
end

%==================================================================================================
function [ok,ilo,ihi,ibeg,frac_beg,iend,frac_end]=get_tbin_range(tbin,tlo_in,thi_in)
% Get the bins that are contained in a time range
%
%   >> [ilo,ihi,ibeg,frac_beg,iend,frac_end]=get_tbin_range(tbin,tlo,thi)
%
%   tbin        Bin boundaries
%   tlo         Array of lower integration limits
%   thi         Array of upper integration limits
%   
%   ilo,ihi     Indicies of bins fully contained in the integration range
%   ibeg        Index of 

tbin=tbin(:);   % make column
dt=diff(tbin);

% Make arrays of integration limits
if ~isscalar(tlo_in) && isscalar(thi_in)
    tlo=max(tlo_in(:),tbin(1));
    thi=min(thi_in*ones(numel(tlo_in),1),tbin(end));
elseif isscalar(tlo_in) && ~isscalar(thi_in)
    tlo=max(tlo_in*ones(numel(thi_in),1),tbin(1));
    thi=min(thi_in(:),tbin(end));
elseif ~numel(tlo_in)==numel(thi_in)
    error('Check sizes of integration limit arrays')
else
    tlo=max(tlo_in(:),tbin(1));
    thi=min(thi_in(:),tbin(end));
end

% Output arrays
ilo=zeros(size(tlo));
ihi=zeros(size(tlo));
ibeg=zeros(size(tlo));
iend=zeros(size(tlo));
frac_beg=zeros(size(tlo));
frac_end=zeros(size(tlo));

% Find whole bins
ok=tlo<thi;
imax=numel(tbin);
for i=find(ok)'
    ilo(i)=min(lower_index(tbin,tlo(i)),imax);
    ihi(i)=max(upper_index(tbin,thi(i)),1);
end

% Find fractional bins
stub=ok & ilo<=ihi & ilo>=2;
frac_beg(stub)=(tbin(ilo(stub))-tlo(stub))./dt(ilo(stub)-1);
ibeg(stub)=ilo(stub)-1;

stub=ok & ilo<=ihi & ihi<imax;
frac_end(stub)=(thi(stub)-tbin(ihi(stub)))./dt(ihi(stub));
iend(stub)=ihi(stub);

stub=ok & ilo>ihi;  % case of lower and upper bounds in the same bin
frac_beg(stub)=(thi(stub)-tlo(stub))./dt(ilo(stub)-1);
ibeg(stub)=ilo(stub)-1;

% Correct ihi
whole=ihi>ilo;
ihi(whole)=ihi(whole)-1;
ilo(~whole)=0;
ihi(~whole)=0;


%==================================================================================================
function [is_lo,is_hi,sp_lo,sp_hi] = get_read_spectra_blocks (speclist)
% Find nearly contiguous blocks of spectra in a sorted list
%
%   >> [is_lo,is_hi,sp_lo,sp_hi] = get_read_spectra_blocks (speclist, max_break)
%
%   speclist    Sorted list of spectra
%   max_break   Maximum break in continuous list that is tolerated within one block
%
%   is_lo, is_hi    Indicies of lower and upper bounds in the array speclist
%   sp_lo, sp_hi    Actual spectrum numbers#


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
