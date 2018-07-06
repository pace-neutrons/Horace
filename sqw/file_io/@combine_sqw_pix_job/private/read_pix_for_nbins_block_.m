function [pix_section,pos_pixstart]=...
    read_pix_for_nbins_block_(obj,fid,pos_pixstart,npix_per_bin,...
    run_label,change_fileno,relabel_with_fnum)
% take range of open input files and
% read pixels blocks corresponding to the input bins block
% provided.
% Inputs:
% fid -- array of open file identifiers.
% pos_pixstart -- binary positions of the start of the pixels
%                 block to process
% npix_per_bin -- 2D array of numbers of pixels per bin per file
%                 within selected bin block
% run_label    -- array of numbers to distinguish one input
%                 file from another. Added to current
% change_fileno-- boolean specifies if pixel info should be
%                 relabelled according to runlabel or filenum
% relabel_with_fnum -- boolean specifies if pixel info should
%                 be relabelled by runlabel or filenum depending
%                 on this switch.
%
npix_per_file = sum(npix_per_bin,2);
n_bin2_process= size(npix_per_bin,2);
nfiles        = size(npix_per_bin,1);
pix_tb=cell(nfiles,n_bin2_process);  % buffer for pixel information

%
bin_filled = false(n_bin2_process,1);
%npixels = 0;

% C++ possibility
%npixels_in_block = sum(npix_per_file);
%npix_per_bin_all_f  = sum(npix_per_bin,1);
%pix_buf_pos  = cumsum(npix_per_bin_all_f)-npix_per_bin_all_f+1;
%pix_section = zeros(9,npixels_in_block);


% Read pixels from input files
for i=1:nfiles
    if npix_per_file(i)>0
        [pix_buf,pos_pixstart(i)] = ...
            obj.read_pixels(fid(i),pos_pixstart(i),npix_per_file(i));
        % may be C++ possibility -- does not work in Matlab
        %                     pix_ind_end   = cumsum(npix_per_bin(i,:));
        %                     pix_ind_start = pix_ind_end-npix_per_bin(i,:)+1;
        %                     pix_section(:,pix_buf_pos(:):pix_buf_pos(:)+npix_per_bin(i,:)) = pix_buf(:,pix_ind_start(:):pix_ind_end(:));
        %                     pix_buf_pos= pix_buf_pos+npix_per_bin(i,:)+1;
        [bin_cell,nonempty_bin] = split_pix_per_bin_(pix_buf,npix_per_bin(i,:),...
            i,run_label(i),change_fileno,relabel_with_fnum);
        pix_tb(i,nonempty_bin) = bin_cell(:);
        %npixels = npixels +numel(pix_tb{i});
        bin_filled(nonempty_bin) = true;
    end
end

% combine pix from all files according to the bin
pix_tb = pix_tb(:,bin_filled); % accelerate combining by removing empty cells
pix_section = cat(2,pix_tb{:});
