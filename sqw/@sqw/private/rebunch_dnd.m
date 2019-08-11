function dout = rebunch_dnd (din, nbunch)
% Rebunch a 1,2,3 or 4 dimensional dataset
%
%   >> dout = rebunch_dnd (din, nbunch)
%
% Input:
% ------
%   din     Input dataset or array of datasets
%   nbunch  Vector that sets the number of bins to be bunched together along
%          each axis
%           If nbunch is scalar, then the value is applied to all dimensions
%           If the original number of bins along an an axis is not an integer
%          multiple of nbunch, then the final bin of the output data set is
%          correspondingly enlarged.
%
% Output:
% -------
%   dout    Rebunched data structure


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)


dout = din;

% Check input parameters
% ----------------------
% Number of plot axes and bins
ndim = length(din.pax);
dims=size(din.s);
if numel(dims)==2 && dims(end)==1
    dims=dims(1:end);
end

if ~all(abs(rem(nbunch,1))==0)
    error('Rebunching can only be by integer number of bins')
end
if isscalar(nbunch)
    nbunch = nbunch*ones(1,ndim);
end

% Catch case of no rebunching or 
if isempty(nbunch) || all(nbunch==1) || all(nbunch==0)
    return
end


% Rebunch
% -------
% Convert nbunch to the order of the plot axes (i.e. axes of s, e, npix)
nbunch(din.dax) = nbunch;

% Get new signal, error, npix arrays
[ind,dims_out] = generate_ind (dims, nbunch);
sz_out=dims_out;
if numel(sz_out)==1
    sz_out = [sz_out,1];
end

keep = (din.npix>0);
ind = ind(keep);

npix = din.npix(keep);
npix_out = accumarray (ind(:),npix(:),[prod(sz_out),1]);
npix_out = squeeze(reshape(npix_out,sz_out));

s = din.s(keep).*npix;
sout = accumarray (ind(:),s(:),[prod(sz_out),1]);
clear('s');
sout = squeeze(reshape(sout,sz_out))./npix_out;

e = din.e(keep).*(npix.^2);
eout = accumarray (ind(:),e(:),[prod(sz_out),1]);
clear('e')
eout = squeeze(reshape(eout,sz_out))./(npix_out.^2);

clear('npix')
null = (npix_out==0);
sout(null) = 0;
eout(null) = 0;

% Find any axes which are now integration axes; update iax,iint,pax,p,dax
now_iax = (dims_out==1);
iax = [din.iax,din.pax(now_iax)];
[dout.iax,ix] = sort(iax);
new_iint = zeros(2,sum(now_iax));
new_p = cell(1,sum(~now_iax));
ii=0; ip=0;
for i=1:ndim
    if now_iax(i)
        ii = ii+1;
        new_iint(:,ii) = [din.p{i}(1);din.p{i}(end)];
    else
        ip = ip+1;
        if dims_out(i)==dims(i)     % no change
            new_p{ip} = din.p{i};
        else
            dp = (din.p{i}(end)-din.p{i}(1))/(numel(din.p{i})-1);
            new_p{ip} = din.p{i}(1) + (nbunch(i)*dp)*(0:dims_out(i))';
        end
    end
end
iint = [din.iint,new_iint];
dout.iint = iint(:,ix);
dout.pax = din.pax(~now_iax);
dout.p = new_p;
dout.dax = din.dax(~now_iax(din.dax));

% Update signal, error and npix arrays
dout.s = sout;
dout.e = eout;
dout.npix = npix_out;


%=================================================================================
function [ind,nbin_out] = generate_ind (nbin, nbunch)
% Generate the indicies of the bins into which rebunched bins belong
%
%   >> [ind,nbin_out] = generate_ind (nbin, nbunch)
%
% Input:
% ------
%   nbin        Number of bins along each plot axis of input dataset
%   nbunch      Array with rebunching along each axis.
%               If scalar, apply to all axes
%
% Output:
% -------
%   ind         Indicies of bins in original array into the rebunched array
%   nbin_out    Number of bins along each plot axis of input dataset after
%              rebunching. One or more elements may be 1 now, which means
%              they are now integration axes


% % Strip outer element from sz if 0D or 1D dataset
% if numel(sz)==2 && sz(2)==1
%     sz=sz(1:end-1);
% end

% Get new size
if isscalar(nbunch), nbunch=nbunch*ones(size(nbin)); end
ix = cell(size(nbin));
nbin_out = zeros(size(nbin));
for i=1:numel(nbin)
    nrep = nbunch(i)*ones(1,floor(nbin(i)/nbunch(i)));
    rm = rem(nbin(i),nbunch(i));
    if rm>0
        nrep = [nrep,rm];
    end
    ix{i} = replicate_iarray (1:numel(nrep),nrep);
    nbin_out(i) = numel(nrep);
end
if numel(nbin)>1
    ixx = ndgridcell(ix);
    ind = sub2ind(nbin_out,ixx{:});
else
    ind = ix{1};
end
