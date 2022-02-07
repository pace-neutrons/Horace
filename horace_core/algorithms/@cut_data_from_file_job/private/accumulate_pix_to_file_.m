function pix_comb_info =accumulate_pix_to_file_(pix_comb_info,finish_accum,v,ix_add,npix,max_buf_size)
% Function to handle case of keep_pixels. Nested so that variables are shared with main function to optimise memory use


persistent n_writ_files; % written files counter
% npix buffer
persistent npix_prev;      % npix at previous flush info
persistent npix_now;       % npix at current cut into

% data buffer:
persistent n_mem_blocks;   % number of data blocks retained in memory
persistent n_pix_in_memory; % number of pixels, stored in memory
persistent pix_mem_retained; % cellarray of pixels blocks in memory to retain
persistent pix_mem_ix_retained; % cellarray of pixels index information blocks in memory to retain

if ischar(pix_comb_info) && strcmp(pix_comb_info,'cleanup')
    clear_memory();
    return
end

if finish_accum && nargin == 2
    pix_comb_info= save_pixels_to_file(pix_comb_info);
    pix_comb_info.npix_cumsum = cumsum(npix_prev(:));

    pix_comb_info  = pix_comb_info.trim_nfiles(n_writ_files);
    
    clear_memory();
    return
end

if isempty(npix_prev)
    % first || clean-up call to the function
    sz = size(npix);
    npix_prev = zeros(sz(:)');
    n_pix_in_memory = v.num_pixels;
    n_mem_blocks = 0;
    n_writ_files = 0;
else
    n_pix_in_memory  = n_pix_in_memory + v.num_pixels;
end
%
npix_now = npix; % npix is accumulated by outer routines (bin_pixels)
if v.num_pixels > 0
    n_mem_blocks = n_mem_blocks + 1;
    pix_mem_retained{n_mem_blocks} = v;    % accumulate pixels into buffer array
    pix_mem_ix_retained{n_mem_blocks} = ix_add;

    new_range_min = min(pix_comb_info.pix_range(1, :), pix_mem_retained{n_mem_blocks}.pix_range(1, :));
    new_range_max = max(pix_comb_info.pix_range(2, :), pix_mem_retained{n_mem_blocks}.pix_range(2, :));
    pix_comb_info.pix_range(1, :) = new_range_min;
    pix_comb_info.pix_range(2, :) = new_range_max;
end

if finish_accum
    pix_comb_info= save_pixels_to_file(pix_comb_info);
    pix_comb_info.npix_cumsum = cumsum(npix(:));

    pix_comb_info  = pix_comb_info.trim_nfiles(n_writ_files);

    clear_memory();
    return
end


if n_pix_in_memory> max_buf_size % flush pixels in file
    pix_comb_info= save_pixels_to_file(pix_comb_info);
end

    function clear_memory()
        clear npix_prev pix_mem_retained pix_mem_ix_retained n_pix_in_memory;
    end


    function pix_comb_info= save_pixels_to_file(pix_comb_info)
        if n_mem_blocks == 0
            return
        end
        npix_in_mem = npix_now - npix_prev;
        npix_prev   = npix_now;
        clear npix_now;
        pix_2write = sort_pix(pix_mem_retained,pix_mem_ix_retained,...
            npix_in_mem,pix_comb_info.pix_range,'-keep_type');
        % clear current memory buffer state;
        n_mem_blocks = 0;
        clear pix_mem_retained pix_mem_ix_retained;

        n_writ_files  = n_writ_files+1;
        file_name = pix_comb_info.infiles{n_writ_files};
        [mess,position] = put_sqw_data_npix_and_pix_to_file_(file_name,npix_in_mem,pix_2write);
        if ~isempty(mess)
            error('HORACE:cut_data_from_file_job:io_error',...
                'put_sqw_data_npix_and_pix_to_file:: Error: %s',mess);
        end
        clear pix_2write;
        pix_comb_info.pos_npixstart(n_writ_files) = position.npix;
        pix_comb_info.pos_pixstart(n_writ_files)  = position.pix;
        pix_comb_info.npix_file_tot(n_writ_files) = n_pix_in_memory;
        % clear too.
        n_pix_in_memory = 0;
    end
end
