function [messages,npix1,npix2] = split_to_messages_for_testing(test_pix_block,nbin_start,nbin_end,n_files,fileind)
% split pix block into messages block
if ~exist('fileind','var')
    fileind = 1:n_files;
end

npix1 = find(test_pix_block(1,:)>=nbin_start,1);
npix2 = find(test_pix_block(1,:)<=nbin_end,1,'last');
proc_pix = test_pix_block(:,npix1:npix2);

payload = struct('npix',[],'bin_range',[nbin_start,nbin_end],'pix_tb',[],...
    'filled_bin_ind',[]);

messages = cell(n_files,1);
for i=1:n_files
    messages{i} = aMessage('data');
    file_ind = proc_pix(2,:)==fileind(i);
    file_pix  = proc_pix(:,file_ind);
    
    payload.npix = size(file_pix,2);
    
    filled_bin_ind = unique(file_pix(1,:))-nbin_start+1;



    n_bin_filled = numel(filled_bin_ind);
    pix_tb = cell(1,n_bin_filled);    
    for j=1:n_bin_filled 
        pix_pos = file_pix(1,:)== filled_bin_ind(j);
        pix_tb{j} = file_pix(:,pix_pos);
    end
    payload.filled_bin_ind = filled_bin_ind;
    payload.pix_tb         = pix_tb;
    messages{i}.payload = payload;
end
