function [pix_section,pos_pixstart]=...
    read_pix_for_nbins_block_(obj,fid,pos_pixstart,npix_per_bin,...
    filenum,run_label,change_fileno,relabel_with_fnum)
% take range of open input files and
% read pixels blocks corresponding to the input bins block
% provided.
% Inputs:
% fid -- array of open file identifiers.
% pos_pixstart -- binary positions of the start of the pixels
%                 block to process
% npix_per_bin -- 2D array of numbers of pixels per bin per file
%                 within selected bin block
% filenum      -- the array of filenumbers, used as pixel labels if
%                 relabel_with_fnum is set to true; Replaces pixel ID in
%                 this case.
% run_label    -- array of numbers to distinguish one input
%                 file from another. Added to current pixel ID
% change_fileno-- boolean specifies if pixel info should be
%                 relabelled according to runlabel or filenum
% relabel_with_fnum -- boolean specifies if pixel info should
%                 be relabelled by runlabel or filenum depending
%                 on this switch.
%
mpis = MPI_State.instance();
is_deployed = mpis.is_deployed;

npix_per_file = sum(npix_per_bin,2);
n_bin2_process= size(npix_per_bin,2);
nfiles        = size(npix_per_bin,1);
pix_tb=cell(nfiles,n_bin2_process);  % buffer for pixel information

%
bin_filled = false(n_bin2_process,1);


% Read pixels from input files
for i=1:nfiles
    if npix_per_file(i)>0
        [pix_buf,pos_pixstart(i)] = ...
            obj.read_pixels(fid(i),pos_pixstart(i),npix_per_file(i));
        [bin_cell,filled_bin_ind] = split_pix_per_bin_(pix_buf,npix_per_bin(i,:),...
            filenum(i),run_label(i),change_fileno,relabel_with_fnum);
        pix_tb(i,filled_bin_ind) = bin_cell(:);
        %npixels = npixels +numel(pix_tb{i});
        bin_filled(filled_bin_ind) = true;
    end
end



pix_tb = pix_tb(:,bin_filled); % accelerate combining by removing empty cells

if is_deployed
    pix_section  = aMessage('data');
    payload = struct('lab',obj.labIndex,'messN',[],'npix',[],...
        'bin_range',[],'pix_tb',[],'filled_bin_ind',[]);
    if nfiles > 1
        % combine pix from all files according to the bin
        pix_buf = cat(2,pix_tb{:});
        % split pixels over bins like it would be a single combined file
        npix_per_bin = sum(npix_per_bin,1);
        [pix_tb,filled_bin_ind] = split_pix_per_bin_(pix_buf,npix_per_bin);
    end
    payload.npix = size(pix_buf,2);
    payload.pix_tb = pix_tb;
    payload.filled_bin_ind = filled_bin_ind;
    
    pix_section.payload = payload;
else
    % combine pix from all files according to the bin
    pix_section = cat(2,pix_tb{:});
    
end
