function pix_comb_info =accumulate_pix_(pix_comb_info,finish_accum,v,ix_add,npix,max_buf_size,log_level)
% Accumulate pixel data into memory and if memory full, to
% temporary files and return a pixfile_combine_info
% object that manages the files.
%
% The pixfile_combine_info object, when saved, will re-combine the temporary
% files into a single sqw object.
%
% Inputs:
% -------
% pix_comb_info    A pixfile_combine_info object
% finish_accum     Boolean flag, set to true to finish accumulation
% v                PixelData object containing pixel chunk
% ix_add           The indices of retained pixels in the order they
%                  appear in output file (used for sorting)
% npix             The npix array associated with this chunk of pixels
% max_buf_size     The maximum buffer size for reading/writing
% npix_retained    Number of pixels retained in this chunk of the cut
% Optional:
% log_level        verbosity of the accumulate algorithm as
%                  defined in hor_config.log_level. If absent,
%                  hor_config.log_level will be used to
%                  define the verbosity.
%
% Internal function Nested so that variables are shared with main function
% to optimise memory use. (Is this too old to care these days?)


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
if nargin<7
    log_level = config_store.instance().get_value('hor_config','log_level');
end

if finish_accum && nargin == 2
    pix_comb_info = finalize_accum(pix_comb_info,log_level);
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

npix_now = npix; % npix is accumulated by outer routines (bin_pixels)

if v.num_pixels > 0
    n_mem_blocks = n_mem_blocks + 1;
    pix_mem_retained{n_mem_blocks} = v;    % accumulate pixels into buffer array
    pix_mem_ix_retained{n_mem_blocks} = ix_add;

    pix_comb_info.data_range = minmax_ranges(pix_comb_info.data_range,pix_mem_retained{n_mem_blocks}.data_range);
end

if finish_accum
    pix_comb_info = finalize_accum(pix_comb_info,log_level);
    return
end


if n_pix_in_memory> max_buf_size % flush pixels in file
    pix_comb_info= save_pixels_to_file(pix_comb_info,log_level);
end

    function pix_comb_info = finalize_accum(pix_comb_info,log_level)
        % finish accumulation and depending on the previous state return
        % either:
        % pifile_combine_info class instance, describing data written to
        % files if any files were written
        % or:
        % PixelDataMemory class, which contains pixels, sorted by bins if
        % any pixels were held in memory.
        if n_writ_files > 0
            pix_comb_info= save_pixels_to_file(pix_comb_info,log_level);
            if exist('npix','var')
                pix_comb_info.npix_cumsum = cumsum(npix(:));
            end

            pix_comb_info  = pix_comb_info.trim_nfiles(n_writ_files);
        else
            if n_pix_in_memory == 0
                pix_comb_info = PixelDataMemory();
            else
                % not keeping precision here as this will be memory-based result
                pix_comb_info  = sort_pix(pix_mem_retained,pix_mem_ix_retained,...
                    n_pix_in_memory,pix_comb_info.data_range);
            end
        end
        clear_memory();

    end

    function clear_memory()
        clear npix_prev pix_mem_retained pix_mem_ix_retained n_pix_in_memory;
    end


    function pix_comb_info= save_pixels_to_file(pix_comb_info,log_level)
        if n_mem_blocks == 0
            return
        end
        npix_in_mem = npix_now - npix_prev;
        npix_prev   = npix_now;
        clear npix_now;
        if log_level>1
            fprintf('*** Sorting selected pixels by the processed  block of image bins:\n')
        end
        % keep sorted pixels precision as they came from file and go to
        % file
        pix_2write = sort_pix(pix_mem_retained,pix_mem_ix_retained,...
            npix_in_mem,pix_comb_info.data_range,'-keep_precision');
        % clear current memory buffer state;
        n_mem_blocks = 0;
        clear pix_mem_retained pix_mem_ix_retained;

        n_writ_files  = n_writ_files+1;
        file_name = pix_comb_info.infiles{n_writ_files};
        if log_level>0
            fprintf('*** Storing sorted pixels to partial sqw file for combining: %s\n', ...
                file_name);
        end

        [mess,position] = put_sqw_data_npix_and_pix_to_file_(file_name,npix_in_mem,pix_2write);
        if ~isempty(mess)
            error('HORACE:cut_data_from_file_job:io_error',...
                'put_sqw_data_npix_and_pix_to_file:: Error: %s',mess);
        end
        clear pix_2write;
        pix_comb_info.pos_npixstart(n_writ_files) = position.npix;
        pix_comb_info.pos_pixstart(n_writ_files)  = position.pix;
        pix_comb_info.npix_each_file(n_writ_files) = n_pix_in_memory;
        % clear too.
        n_pix_in_memory = 0;
    end
end