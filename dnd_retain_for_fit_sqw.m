function sel = dnd_retain_for_fit_sqw (din, pkeep, premove, mask)
% Determine the points to keep on the basis of ranges and mask array for fit_sqw
% Needed as fit_sqw operforms a linear trnsformation from plot coordinates to rlu
% before calling the generic fit routine.
% Does NOT find array elements with zero error bars, NaN data values etc. This is
% performed inside the generic fit routine.
%
% Syntax:
%   >> sel = dnd_retain_for_fit_sqw (din, xkeep, xremove, mask)
%
%   din     Data structure with contents of dataset
%   pkeep   Hypercuboids with regions to retain for fit
%   premove Hypercuboids with regions to remove from fit
%   mask    Mask array of same number of elements as data array: 1 to keep, 0 to remove
%
%   sel     Mask array of same number of elements as data of points to keep.
%           Returned as a column vector.

% Check input parameters
ndim=length(din.pax);
if ~isempty(pkeep)
    if size(pkeep,2)/2~=ndim || length(size(pkeep))~=2
        error(['''keep'' must provide a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'])
    end
end
if ~isempty(premove)
    if size(premove,2)/2~=ndim || length(size(premove))~=2
        error(['''remove'' must provide a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'])
    end
end
if ~isempty(mask)
    if numel(mask)~=numel(din.s)
        error(['''mask'' must provide a numeric or logical array with same number of elements as the data'])
    end
end

% Sort the ranges
if ~isempty(pkeep)
    nk=size(pkeep,1);
    tmp=reshape(pkeep,[nk,2,ndim]);
    pkeep_lo=min(tmp,[],2);
    pkeep_hi=max(tmp,[],2);
    keep_volume=true(nk);      % true if the range is in the data volume, false otherwise
    iklo=ones(nk,4);
    ikhi=ones(nk,4);
else
    nk=0;
end

if ~isempty(premove)
    nr=size(premove,1);
    tmp=reshape(premove,[nr,2,ndim]);
    premove_lo=min(tmp,[],2);
    premove_hi=max(tmp,[],2);
    remove_volume=true(nr);   % true if the range is in the data volume, false otherwise
    irlo=ones(nr,4);
    irhi=ones(nr,4);
else
    nr=0;
end

% Find indicies of sub-sections of the data array of points to keep and remove
for idim=1:ndim
    pcent=0.5*(din.(['p',int2str(idim)])(1:end-1)+din.(['p',int2str(idim)])(2:end));
    for ik=1:nk
        % find indicies of points to keep for each range along the given axis
        ind=find(pcent>=pkeep_lo(ik,1,idim) & pcent<=pkeep_hi(ik,1,idim));
        if ~isempty(ind)
            iklo(ik,idim)=ind(1);
            ikhi(ik,idim)=ind(end);
        else
            keep_volume(ik)=false;
        end
    end
    for ir=1:nr
        % find indicies of points to remove for each range along the given axis
        ind=find(pcent>=premove_lo(ir,1,idim) & pcent<=premove_hi(ir,1,idim));
        if ~isempty(ind)
            irlo(ir,idim)=ind(1);
            irhi(ir,idim)=ind(end);
        else
            remove_volume(ir)=false;
        end
    end
end

% Now remove the points
if ~isempty(pkeep)
    keep = false(size(din.s));
    for ik=1:nk
        if keep_volume(ik)
            keep(iklo(ik,1):ikhi(ik,1),iklo(ik,2):ikhi(ik,2),iklo(ik,3):ikhi(ik,3),iklo(ik,4):ikhi(ik,4)) = true;
        end
    end
else
    keep = true(size(din.s));
end

if ~isempty(premove)
    remove = false(size(din.s));
    for ir=1:nr
        if remove_volume(ir)
            remove(irlo(ir,1):irhi(ir,1),irlo(ir,2):irhi(ir,2),irlo(ir,3):irhi(ir,3),irlo(ir,4):irhi(ir,4)) = true;
        end
    end
else
    remove = false(size(din.s));
end

if ~isempty(mask)
    mask=logical(reshape(mask,size(din.s))); % initialise output selection array
else
    mask=true(size(din.s));
end

sel = keep & ~remove & mask;
sel = reshape(sel,[numel(sel),1]);
