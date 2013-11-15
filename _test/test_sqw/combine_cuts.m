function wtot=combine_cuts(w)
% Combine cuts.
%
%   >> wtot=combine_cuts(w)
%
% Assumes that combining is valid - no checks performed.

nw=numel(w);
if nw==1    % catch case of single cut
    wtot=w;
    return
end

nfiles=zeros(1,nw);
npixtot=zeros(1,nw);
for i=1:nw
    nfiles(i)=w(i).main_header.nfiles;
    npixtot(i)=size(w(i).data.pix,2);
end

% Construct main header
main_header.filename='';
main_header.filepath='';
main_header.title='';
main_header.nfiles=sum(nfiles);

% Construct header
nend_f=cumsum(nfiles);
nbeg_f=nend_f-nfiles+1;
header=cell(nend_f(end),1);
for i=1:nw
    if nbeg_f(i)==nend_f(i)
        header(nbeg_f(i):nend_f(i))={w(i).header};
    else
        header(nbeg_f(i):nend_f(i))=w(i).header;
    end
end

% Construct data
nbin=size(w(1).data.npix,1);
npix=zeros(nbin,1);
nend=cumsum(npixtot);
nbeg=nend-npixtot+1;
pix=zeros(9,nend(end));
ibin=zeros(1,nend(end));
for i=1:numel(w)
    npix=npix+w(i).data.npix;
    pix(:,nbeg(i):nend(i))=w(i).data.pix;
    pix(5,nbeg(i):nend(i))=pix(5,nbeg(i):nend(i))+(nbeg_f(i)-1);
    ibin(nbeg(i):nend(i))=replicate_array(1:nbin,w(i).data.npix);
end
[ibin,ix]=sort(ibin);
pix=pix(:,ix);

data=w(1).data;
data.npix=npix;
data.pix=pix;

% Build final object
wtot.main_header=main_header;
wtot.header=header;
wtot.detpar=w(1).detpar;
wtot.data=data;

wtot=recompute_bin_data(wtot);
wtot=sqw(wtot);


%----------------------------------------------------------------------------------------
function vout = replicate_array (v, npix)
% Replicate array elements according to list of repeat indicies
%
%   >> vout = replicate_array (v, n)
%
%   v       Array of values
%   n       List of number of times to replicate each value
%
%   vout    Output array: column vector
%               vout=[v(1)*ones(1:n(1)), v(2)*ones(1:n(2), ...)]'

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if numel(npix)==numel(v)
    % Get the bin index for each pixel
    nend=cumsum(npix(:));
    nbeg=nend-npix(:)+1;    % nbeg(i)=nend(i)+1 if npix(i)==0, but that's OK below
    nbin=numel(npix);
    npixtot=nend(end);
    vout=zeros(npixtot,1);
    for i=1:nbin
        vout(nbeg(i):nend(i))=v(i);     % if npix(i)=0, this assignment does nothing
    end
else
    error('Number of elements in input array(s) incompatible')
end

%----------------------------------------------------------------------------------------
function wout=recompute_bin_data(w)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents of pix array
%
%   >> wout=recompute_bin_data(w)

% See also average_bin_data, which uses en essentially the same algorithm. Any changes
% to the one routine must be propagated to the other.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

wout=w;

% Get the bin index for each pixel
nend=cumsum(w.data.npix(:));
nbeg=nend-w.data.npix(:)+1;
nbin=numel(w.data.npix);
npixtot=nend(end);
ind=zeros(npixtot,1);
for i=1:nbin
    ind(nbeg(i):nend(i))=i;
end

% Accumulate signal
wout.data.s=accumarray(ind,w.data.pix(8,:),[nbin,1])./w.data.npix(:);
wout.data.s=reshape(wout.data.s,size(w.data.npix));
wout.data.e=accumarray(ind,w.data.pix(9,:),[nbin,1])./(w.data.npix(:).^2);
wout.data.e=reshape(wout.data.e,size(w.data.npix));
nopix=(w.data.npix(:)==0);
wout.data.s(nopix)=0;
wout.data.e(nopix)=0;
