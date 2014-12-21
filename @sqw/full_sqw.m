function w=full_sqw(dummy_sqw, d)
% Create full format sqw object from a sparse sqw data structure
%
%   >> w = full_sqw (dummy_sqw, d)
%
% Input:
% ------
%   dummy_sqw   Dummy sqw object  - used only to ensure that this service routine was called
%
%   d           Data structure (or array of data structures) with same format as sqw object,
%               with the following exceptions:
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
%
% Output:
% -------
%   w       sqw object (or array of sqw objects)
%


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


nw=numel(d);
if nw==1
    w=full_sqw_single(d);
elseif nw>1
    w=repmat(sqw,size(d));
    for i=1:nw
        w(i)=full_sqw_single(d(i));
    end
else
    w=repmat(sqw,[0,0]);
end


%==================================================================================================
function w = full_sqw_single(d)

% Fill main header, header and detector sections
% -------------------------------------------------
w.main_header=d.main_header;
w.header=d.header;
w.detpar=d.detpar;

% Fill data section
% -----------------
data=d.data;    % just a pointer, and saves on overheads resolving later

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

% Get size of s,e,n arrays
nd=numel(data.pax);
szarr=ones(1,max(nd,2));
for i=1:nd
    szarr(i)=length(data.p{i})-1;
end

% Fill sparse data section:
data_new.s=reshape(full(data.s),szarr);
data_new.e=reshape(full(data.e),szarr);
data_new.npix=reshape(full(data.npix),szarr);

if isfield(data,'pix')  % is sqw-type
    data_new.urange=data.urange;
    
    nfiles=d.main_header.nfiles;
    [kfix,emode,ne,k,en,spec_to_pix]=header_calc_ucoord_info(d.header);
    ndet=numel(d.detpar.x2);
    detdcn = calc_detdcn(d.detpar);
    
    data_new.pix = pix_sparse_to_full(data.pix,data.pix_nz,1,max(ne),ndet);
    
    if nfiles==1
        data_new.pix(1:4,:) = calc_ucoords_singlerun (kfix, emode, k{1}, en{1}, detdcn,...
            spec_to_pix{1}, data_new.pix(6,:), data_new.pix(7,:));
    else
        data_new.pix(1:4,:) = calc_ucoords_multirun (kfix', emode, cell2arr(k,true), cell2arr(en,true), detdcn,...
            cell2arr(spec_to_pix), data_new.pix(5,:), data_new.pix(6,:), data_new.pix(7,:));
    end
end

w.data=data_new;
w=sqw(w);
