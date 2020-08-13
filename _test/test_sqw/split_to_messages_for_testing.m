function [messages,npix1,npix2,last_bin_completed] = split_to_messages_for_testing(test_pix_block,...
    nbin_start,nbin_end,n_files,fileind,buf_size,npix1)
% split pix block into messages block. e.g prepare n_files messages, whith
% pixels, contributing into these bins.
%
% inputs:
% test_pix_block -- array with test information for splitting pixels (see
%                   build_pix_block_for_testing for the details)
% nbin_start     -- first bin to prepare for messages
% nbin_end       -- last bin to prepaste for messages
% n_files        -- number of messages to split pix_block into (the info
%                   about splitting mess position is stored in the second
%                   column of the pix_block)
% fileind        -- auxiliary information, specifying the indexes of files
%                   to process messages (numel(fileind)== n_files)
% Optional:
% buf_size       -- if present, constrain the number of pixels, moved to
%                   messages by this number
% npix1          -- if present, the first pixel to use to define the range
%                   instead of the first bin number
%
% Output:
% messages       -- cellarray of messages containing pix information. See
%                   pix_cache about the format of these messages
%
%npix1 - number of the first pixel, contributing into the first bin
%        requested
%npix2 - number of the last pixel, contributing into the bins requested
%
% last_bin_completed -- if true, the messages contain full bins. If false,
% some pixels from the bin are not fitting the buffer and will be placed in
% messages later.

if ~exist('fileind','var')
    fileind = 1:n_files;
end
if nargin<6
    npix1 = find(test_pix_block(1,:)>=nbin_start,1);
end

npix2 = find(test_pix_block(1,:)<=nbin_end,1,'last');
npix_to_split = npix2-npix1+1;
if nargin<5
    last_bin_completed = true;
else
    if buf_size>=npix_to_split
        last_bin_completed = true;
    else
        npix2 = npix1+buf_size-1;
        nbin_end = test_pix_block(1,npix2);
        if npix2>=size(test_pix_block,2)
            npix2 = size(test_pix_block,2);
            last_bin_completed = true;
        else
            nbin_next = test_pix_block(1,npix2+1);
            if nbin_next == nbin_end
                last_bin_completed = false;
            else
                last_bin_completed = true;
            end
        end
    end
end



payload = struct('npix',[],'n_source',0,'bin_range',[nbin_start,nbin_end],'pix_tb',[],...
    'filled_bin_ind',[],'last_bin_completed',true);

proc_pix = test_pix_block(:,npix1:npix2);
if ~last_bin_completed
    bin_edge  = find(test_pix_block(1,:)<=nbin_end,1,'last');
    pix_tail = test_pix_block(:,npix2:bin_edge);
end
messages = cell(n_files,1);
all_fpix_in_bin = true;
for i=1:n_files
    messages{i} = DataMessage();
    file_ind = proc_pix(2,:)==fileind(i);
    file_pix  = proc_pix(:,file_ind);
    payload.n_source = i;
    %
    if ~last_bin_completed
        pix_left = pix_tail(2,:)==fileind(i);
        if any(pix_left)
            all_fpix_in_bin  = false;
        end
    end
    payload.last_bin_completed = all_fpix_in_bin;
    
    payload.last_bin_completed = true;
    payload.npix = size(file_pix,2);
    
    filled_bin_nums = unique(file_pix(1,:));
    filled_bin_ind  = filled_bin_nums - nbin_start+1;
    
    
    n_bin_filled = numel(filled_bin_ind);
    pix_tb = cell(1,n_bin_filled);
    for j=1:n_bin_filled
        pix_pos = file_pix(1,:)== filled_bin_nums(j);
        pix_tb{j} = file_pix(:,pix_pos);
    end
    payload.filled_bin_ind = filled_bin_ind;
    payload.pix_tb         = pix_tb;
    messages{i}.payload    = payload;
end
