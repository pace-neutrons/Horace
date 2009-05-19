function wout=recompute_bin_data(w,varargin)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents of pix array
%
%   >> wout=recompute_bin_data(w)
%   >> wout=recompute_bin_data(w,npix_other)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)
%
% Modified by R.A. Ewings to account for a rather special set of
% circumstances when you wish to perform a binary operation on an sqw
% object and a dnd object.

if nargin==1
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

%===
elseif nargin==2

    npix_other=varargin{1};
    wout=w;

    %We must first work out which pixels we want to remove completely from the
    %data
    ok=(w.data.npix>0 & npix_other>0);%tells us which pixel groups can be retained
    todelete=w.data.npix.*(~ok);
    tokeep=w.data.npix.*ok;

    % Get the bin index for each pixel
    nend=cumsum(w.data.npix(:));
    nbeg=nend-w.data.npix(:)+1;
    nbin=numel(w.data.npix);
    npixtot_old=nend(end);
    for i=1:nbin
        if ~ok(i) && nend(i)~=0
            w.data.pix(:,[nbeg(i):nend(i)])=[];
            nbeg=nbeg-todelete(i); nend=nend-todelete(i);
        end
    end

    w.data.npix=tokeep;
    w.data.s=w.data.s.*ok;
    w.data.e=w.data.e.*ok;


    % Get the bin index for each pixel again
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
    wout.data.npix=w.data.npix;
else
    error('ERROR: incorrect number of arguments to recompute_bin_data. Horace logic flaw');
end

