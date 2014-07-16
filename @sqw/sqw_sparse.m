function d = sqw_sparse (w)
% Create sparse format sqw data structure (not an object) for an sqw object with just one spe file.
%
%   >> d = sqw_sparse (w)
%
% Input:
% ------
%   w       sqw object of sqw type (a dnd-type sqw object will cause a failure)
%
% Output:
% -------
%   d       data structure with same format as sqw object, with the following exceptions:
%
%           d.detpar:
%           ---------
%           Only one field:
%                   ndet    Number of detectors in the detector parameter structure
%   
%           d.data:
%           -------
%           Has fields filename,...,uoffset,...,dax as in the sqw object, and then:
%                   s       Average signal in the bins as a sparse column vector
%                   e       Corresponding variance in the bins as a sparse column vector
%                   npix    Number of contributing pixels as a sparse column vector
%                   urange  <as in sqw object>
%                   npix_nz Number of pixels in each bin with pixels with non-zero counts (sparse column vector)
%                   ipix_nz Index of pixels into pix array with non-zero counts
%                   pix_nz  Array with idet,ien,s,e for the pixels with non-zero signal sorted so that 
%                          all the pixels in the first bin appear first, then all the pixels in the second bin etc.
%                   pix     Index of pixels, sorted so that all the pixels in the first 
%                          bin appear first, then all the pixels in the second bin etc. (column vector)
%                                   ipix0 = ie + ne*(id-1)
%                               where
%                                   ie  energy bin index
%                                   id  detector index into list of all detectors (i.e. masked and unmasked)
%                                   ne  number of energy bins


ne=numel(w.header.en)-1;

% Fill main header, header and detector sections
% -------------------------------------------------
d.main_header=w.main_header;
d.header=w.header;
d.detpar=w.detpar;

% Fill data section
% -----------------
data=w.data;    % just a pointer, and saves on overheads resolving later
npix=data.npix; % just a pointer, and saves on overheads resolving later
pix=data.pix;   % just a pointer, and saves on overheads resolving later

data_new.filename=data.filename;
data_new.filepath=data.filepath;
data_new.title=data.title;
data_new.alatt=data.alatt;
data_new.angdeg=data.angdeg;
data_new.uoffset=data.uoffset;
data_new.u_to_rlu=data.u_to_rlu;
data_new.ulen=data.ulen;
data_new.ulabel=data.ulabel;
data_new.iax=data.iax;
data_new.iint=data.iint;
data_new.pax=data.pax;
data_new.p=data.p;
data_new.dax=data.dax;

% Fill sparse data section:
% - Information about contribution of pixels to bins
ok=(npix(:)>0);
ibin=find(ok);  % bin indicies with at least one pixel

data_new.s=sparse(ibin,1,data.s(ok),numel(ok),1);
data_new.e=sparse(ibin,1,data.e(ok),numel(ok),1);
data_new.npix=sparse(npix(:));

data_new.urange=data.urange;

% - Information about contribution of pixels with non-zero counts to bins
nonempty=(pix(8,:)~=0);     % logical index of pixel with non-zero signal
ibin=replicate_iarray(1:numel(npix),npix);      % bin indicies for each pixel
ibin_nz=ibin(nonempty);     % bin indicies of pixels with non-zero signal
npix_nz=accumarray(ibin_nz,1,[numel(npix),1]);  % number of pixels with non-zero signal in each bin

data_new.npix_nz=sparse(npix_nz);
data_new.ipix_nz=ibin_nz;
data_new.pix_nz=pix(6:9,nonempty);

% - Index of pixels
data_new.pix=(pix(7,:)+ne*(pix(6,:)-1))';

d.data=data_new;
