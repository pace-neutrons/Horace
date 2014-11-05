function [mem_npix,mem_npix_nz,mem_pix_nz,mem_pix]=sources_file_mem_req(S)
% Determine how much memory is required to hold npix and pix arrays for sqw data in files
%
%   >> [mem_npix,mem_npix_nz,mem_pix_nz,mem_pix]=sources_file_mem_req(S)
%
% Input:
% ------
%   S           Cell array of filled sqwfile structures (can be open or closed files)
%               Empty elements of S are ignored.
%
% Output:
% -------
%   mem_npix    Memory required to hold npix (bytes)
%   mem_npix_nz Memory required to hold npix (bytes)
%   mem_pix_nz  Memory required to hold npix (bytes)
%   mem_pix     Memory required to hold npix (bytes)


% Original author: T.G.Perring
%
% $Revision: 890 $ ($Date: 2014-08-31 16:32:12 +0100 (Sun, 31 Aug 2014) $)


mem=zeros(4,1);
for i=1:numel(S)
    if ~isempty(S{i})
        mem = mem + sources_file_mem_req_single(S{i});
    end
end
mem_npix=mem(1);
mem_npix_nz=mem(2);
mem_pix_nz=mem(3);
mem_pix=mem(4);


%--------------------------------------------------------------------------------------------------
function mem = sources_file_mem_req_single(S)
% Determine how much memory is required to hold npix and pix arrays for sqw data in a file
%
%   >> mem = sources_file_mem_req_single(S)
%
% Input:
% ------
%   S       Filled sqwfile structure (can be open or closed file)
%
% Output:
% -------
%   mem     Array with required [mem_npix, mem_npix_nz, mem_pix_nz, mem_pix]
%
% The memory requirements may not be exact: they are computed on the basis of
% the number of elements in the arrays (and non-zero elements in the case of
% sparse arrays), but the overheads associated with the storage were empirically
% determined for a few test examples in R2014a on a Windows 7 laptop.
% The overheads will be small in comparison to realistic sizes of the various arrays.
% If the number of elements is sufficiently small that the overheads are
% relatively large the the absolute memory requirements will be small compared
% to realistic amounts

mem=zeros(4,1);

% Get number of elements in npix
info=S.info;

% Compute memory
if info.sparse
    if info.nfiles~=1
        ncol=5;
    else
        ncol=4;
    end
    mem(1)=16*info.nz_npix + 16;    % Tested 2014a on Win7; extra 16 bytes overhead
    mem(2)=16*info.nz_npix_nz + 16;
    mem(3)=8*ncol*info.npixtot_nz;
    mem(4)=8*info.npixtot;
else
    if info.ndims>0
        nbins=prod(info.sz(1:info.ndims));
    else
        nbins=1;    % zero dimensional sqw object
    end
    mem(1)=8*nbins;
    mem(2)=0;
    mem(3)=0;
    mem(4)=8*(9*info.npixtot);
end
