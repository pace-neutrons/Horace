function [pix_section,pos_pixstart]=...
    read_pix_for_nbins_block_(obj,pos_pixstart,npix_per_bin)
% take range of open input files and
% read pixels blocks corresponding to the input bins block
% provided.
% Inputs:
%                 block to process
% npix_per_bin -- 2D array of numbers of pixels per bin per file
%                 within selected bin block
%
mpis = MPI_State.instance();
is_deployed = mpis.is_deployed;

% pos_pixstart -- binary positions of the start of the pixels
pix_comb_info = obj.pix_combine_info_;
% relabel_with_fnum -- boolean specifies if pixel info should
%                 be relabelled by runlabel or filenum depending
%                 on this switch.
relabel_with_fnum= pix_comb_info.relabel_with_fnum;
% change_fileno-- boolean specifies if pixel info should be
%                 relabelled according to runlabel or filenum
change_fileno    = pix_comb_info.change_fileno;
% run_label    -- array of numbers to distinguish one input
%                 file from another. Added to current pixel ID
run_label        = pix_comb_info.run_label;
% filenum      -- the array of filenumbers, used as pixel labels if
%                 relabel_with_fnum is set to true; Replaces pixel ID in
%                 this case.
filenum          = pix_comb_info.filenum;


npix_per_file = sum(npix_per_bin,2);
n_bin2_process= size(npix_per_bin,2);
nfiles        = size(npix_per_bin,1);
pix_tb=cell(nfiles,n_bin2_process);  % buffer for pixel information

%
bin_filled = false(n_bin2_process,1);
if ischar(run_label)
    if strcmpi(run_label,'nochange')
        run_label = filenum; % will not be used, just to keep common 
        % interface to split_pix_per_bin_
    else
        error('READ_PIXELS:invalid_argument',...
        'If runlabel is a character string, it can be only "nochange". Got: %s',...
        run_label);        
    end
end


% Read pixels from input files
for i=1:nfiles
    if npix_per_file(i)>0
        [pix_buf,pos_pixstart(i)] = ...
            obj.read_pixels(i,pos_pixstart(i),npix_per_file(i));
        [bin_cell,filled_bin_ind] = split_pix_per_bin_(pix_buf,npix_per_bin(i,:),...
            filenum(i),run_label(i),change_fileno,relabel_with_fnum);
        pix_tb(i,filled_bin_ind) = bin_cell(:);
        %npixels = npixels +numel(pix_tb{i});
        bin_filled(filled_bin_ind) = true;
    end
end



pix_tb = pix_tb(:,bin_filled); % accelerate combining by removing empty cells

if is_deployed
    % the number of data reader in the list of readers
    n_source = obj.labIndex-obj.reader_id_shift_;
    %
    payload = obj.mess_struct_;
    payload.n_source = n_source;

    if nfiles > 1
        % combine pix from all files according to the bin
        pix_buf = cat(2,pix_tb{:});
        % split pixels over bins like it would be a single combined file
        npix_per_bin = sum(npix_per_bin,1);
        %[pix_tb,filled_bin_ind] = split_pix_per_bin_(pix_buf,npix_per_bin);
    end
    % the positions of pixels block in linear array of pixels
    bin_edges =[1,cumsum(npix_per_bin)+1];
    payload.npix = size(pix_buf,2);
    payload.pix_data = pix_buf;
    payload.bin_edges = bin_edges';
    
    pix_section  = DataMessage(payload);    
else
    % combine pix from all files according to the bin
    pix_section = cat(2,pix_tb{:});
    
end
