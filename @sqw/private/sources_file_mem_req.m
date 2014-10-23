function [mem_npix,mem_npix_nz,mem_pix_nz,mem_pix]=sources_file_mem_req(S)
% Determine how much memory is required to hold npix and pix arrays for sqw data in files
%
%
%   >> [mem_npix,mem_npix_nz,mem_pix_nz,mem_pix]=memory_allocation(S)
%
% Input:
% ------
%   S           Cell array of filled sqwfile structures (can be open or closed files)
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


mem_npix=0;
mem_npix_nz=0;
mem_pix_nz=0;
mem_pix=0;

mem=zeros(1,4);
for i=1:numel(S)
    if ~isempty(S{i})
        mem = mem + sources_file_mem_req_single(S);
    end
end

