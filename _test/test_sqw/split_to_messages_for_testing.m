function [messages,npix_end,nbin_end] = split_to_messages_for_testing(pix_file_data,...
    npix_start,nbin_start,buf_size,nbin_total)
% split pix block into messages block. e.g prepare n_files messages, whith
% pixels, contributing into these bins.
%
% inputs:
% pix_file_data -- cellarray, containing pix info separated into "files" as
%                  in build_pix_block_for_testing. See this routine for the
%                  details.
% npix_start     -- first pixel to read for messages
% nbin_start     -- first bin to use for messages (defines bin range)
% buf_size       -- the number of pixels to process per split operation
%
% Output:
% messages       -- cellarray of messages containing pix information. See
%                   pix_cache about the format of these messages


n_files = numel(pix_file_data);

if numel(nbin_start)==1
    nbin_start = ones(n_files,1)*nbin_start;
end
if numel(npix_start)==1
    npix_start = ones(n_files,1)*npix_start;
end
npix_end = npix_start;
nbin_end = nbin_start;


payload = struct('npix',[],'n_source',0,'bin_range',[0,0],'pix_data',[],...
    'bin_edges',[],'flld_bin_ind',[],'last_bin_completed',true);


messages = cell(n_files,1);

for i=1:n_files
    data = pix_file_data{i};
    messages{i} = DataMessage();
    npix1 = npix_start(i);
    npix_end(i) = npix1+buf_size-1;
    npix_start(i) = npix_end(i)+1;
    
    if npix_end(i) >size(data,2)
        npix_end(i) = size(data,2);
        npix_start(i) = npix_end(i)+1;
    end
    npix2 = npix_end(i);
    if npix1>npix2
        messages{i} = [];
        continue;
    end
    pix_tb = data(:,npix1:npix2);
    
    nbin_end_i   = pix_tb(1,end);
    payload.bin_range = [nbin_start(i),nbin_end_i];
    
    
    %
    payload.n_source = i;        % last bin
    if (npix2 == size(data,2) || data(1,npix2)~=data(1,npix2+1))
        payload.last_bin_completed =true;
        if (npix2 == size(data,2))
            payload.bin_range(2) =  nbin_total;
            nbin_end_i = nbin_total;
        end
        nbin_end(i) = nbin_end_i+1;
    else
        payload.last_bin_completed =false;
        nbin_end(i) = nbin_end_i;
    end
    payload.npix = size(pix_tb,2);
    
    [flld_bin_ind,bin_edges] = unique(pix_tb(1,:));
    bin_edges  = [bin_edges;payload.npix+1] ;
    
    bin_sequence = nbin_start(i):nbin_end_i;
    if numel(bin_sequence)>numel(flld_bin_ind)
        
        % expand bin edges with zero bins
        bin_edges_expanded = zeros(numel(bin_sequence)+1,1);
        n_bin = 1;
        for j=1:numel(bin_sequence)
            
            bin_edges_expanded(j) = bin_edges(n_bin);
            if n_bin<=numel(flld_bin_ind) && bin_sequence(j)==flld_bin_ind(n_bin)
                n_bin = n_bin+1;
            end
        end
        bin_edges_expanded(end) = bin_edges(end);
        
        bin_edges = bin_edges_expanded;
    end
    
    payload.bin_edges      = bin_edges;
    payload.pix_data       = pix_tb;
    messages{i}.payload    = payload;
end

non_empty = cellfun(@(ms)(~isempty(ms)),messages,'UniformOutput',true);
messages = messages(non_empty);
