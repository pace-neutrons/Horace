function d = sparse (w)
% Create sparse format sqw data structure (not an object) from an sqw object
%
%   >> d = sparse (w)
%
% Input:
% ------
%   w       sqw object of (sqw type or dnd-type)
%
% Output:
% -------
%   d       data structure with same format as sqw object, with the following exceptions:
%
%       data.s          Average signal in the bins (sparse column vector)
%       data.e          Corresponding variance in the bins (sparse column vector)
%       data.npix       Number of contributing pixels to each bin as a sparse column vector
%       data.urange     <same as non-sparse sqw object:
%                       True range of the data along each axis [urange(2,4)]. This is in the
%                      coordinates of the plot/integration projection axes, NOT the projection
%                      axes of the individual pixel info.>
%       data.npix_nz    Number of non-zero pixels in each bin (sparse column vector)
%       data.pix_nz Array with columns containing [id,ie,s,e]' for the pixels with non-zero
%                  signal sorted so that all the pixels in the first bin appear first, then
%                  all the pixels in the second bin etc. Here
%                           ie      In the range 1 to ne (the number of energy bins
%                           id      In the range 1 to ndet (the number of detectors)
%                  but these are NOT the energy bin and detector indicies of a pixel; instead
%                  they are the pair of indicies into the location in the pix array below.
%                           ind = ie + ne*(id-1)
%
%                   If more than one run contributed, array contains ir,id,ie,s,e, where
%                           ir      In the range 1 to nrun (the number of runs)
%                  In this case, ir adds a third index into the pix array, and 
%                           ind = ie + max(ne)*(id-1) + ndet*max(ne)*(ir-1)
%
%       data.pix    Pixel index array, sorted so that all the pixels in the first
%                  bin appear first, then all the pixels in the second bin etc. (column vector)
%                   The pixel index is defined by the energy bin number and detector number:
%                           ipix = ien + ne*(idet-1)
%                       where
%                           ien     energy bin index
%                           idet    detector index into list of all detectors (i.e. masked and unmasked)
%                           ne      number of energy bins
%
%                   If more than one run contributed, then
%                           ipix = ien + max(ne)*(idet-1) + ndet*max(ne)*(irun-1)
%                       where in addition
%                           irun    run index
%                           ne      array with number of energy bins for each run
%
%               If option is to read npix, npix_nz, pix_nz or pix, then data is a single array:
%                   opt.npix    npix arrayarray (or column vector if range present, length=diff(range))
%                   opt.pix     [9,npixtot] array (or [9,n] array if range present, n=diff(range))


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


nw=numel(w);
if nw>=1
    d=sparse_single(w);
    if nw>1
        d=repmat(d,size(w));
        for i=2:nw
            d(i)=sparse_single(w(i));
        end
    end
else
    d=struct([]);
end


%==================================================================================================
function d = sparse_single(w)

% Fill main header, header and detector sections
% -------------------------------------------------
d.main_header=w.main_header;
d.header=w.header;
d.detpar=w.detpar;

% Fill data section
% -----------------
data=w.data;    % just a pointer, and saves on overheads resolving later

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
data_new.s=sparse(data.s(:));
data_new.e=sparse(data.e(:));
data_new.npix=sparse(data.npix(:));

if is_sqw_type(w)
    data_new.urange=data.urange;
    
    nfiles=w.main_header.nfiles;
    ndet=numel(w.detpar.x2);
    if nfiles==1
        ne=numel(w.header.en)-1;
    else
        ne=zeros(nfiles,1);
        header=w.header;
        for i=1:nfiles
            ne(i)=numel(header{i}.en)-1;
        end
    end
    [data_new.npix_nz,data_new.pix_nz,data_new.pix] =...
        pix_full_to_sparse(data.pix,data.npix,ne,ndet);
end

d.data=data_new;
