function wout = section (win,varargin)
% Takes a section out of an sqw object
%
% This is essentially a cut from the DnD without recomputing bins
%  and extracts the bins wholesale from the underlying object
% This makes the process more efficient but does not allow transformation of projections
%
%   >> wout = section (win, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi], ...)
%
% Input:
% ------
%   win                 Input sqw object
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis. Bins are retained whose
%                      centres lie in this range.
%                       To retain the limits of the input structure, type '', [], or the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%           :                       :
%
%       for as many axes as there are plot axes
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: to alter the limits of the first and third axes of a 3D sqw object:
%   >> wout = section (win, [1.9,2.1], [], [-0.55,-0.45])


% Original author: T.G.Perring
%

% Trivial case of no section arguments
if isempty(varargin)
    wout = copy(win);
    return
end

% Dimension of input data structures
ndim=dimensions(win(1));
if ndim==0  % no sectioning possible
    error('HORACE:sqw:invalid_argument', 'Cannot section a zero dimensional object')
end

if numel(win) > 1 && any(arrayfun(@dimensions, win(2:end)) ~= ndim)
    error('HORACE:sqw:invalid_argument', 'All objects must have same dimensionality for sectioning to work')
end

if length(varargin) ~= ndim
    error('HORACE:sqw:invalid_argument', 'Check number of arguments')
end

% Initialise output argument
wout = copy(win);

tol=4*eps('single');    % acceptable tolerance: bin centres deemed contained in new boundaries

for n = 1:numel(win)
    [wout(n).data, new_axis] = section(wout(n).data, varargin{:});

    % Section the pix array, if sqw type, and update img_range
    if has_pixels(win(n))

        % get contiguous ranges of pixels to be retained
        [bl_start,bl_size] = get_nrange(win(n).data.proj, ...
                                        win(n).data.npix, ...
                                        win(n).data.axes, ...
                                        new_axis, ...
                                        win(n).data.proj);

        if win(n).pix.is_filebacked
            chunk_size = get(hor_config, 'mem_chunk_size');

            block_chunks = split_data_blocks(bl_start, bl_size, chunk_size);
            num_chunks = numel(block_chunks);

            wout(n) = wout(n).get_new_handle();

            pix_ind = 1;

            new_pix_range = [];
            for iter = 1:num_chunks
                chunk = block_chunks{iter};
                pix_start = chunk{1};
                block_sizes = chunk{2};

                data = win(n).pix.get_pix_in_ranges(pix_start, block_sizes, false, false);

                new_pix_range = minmax_ranges(new_pix_range, data.pix_range);

                wout(n).pix = wout(n).pix.format_dump_data(data.data);

                pix_ind = pix_ind + data.num_pixels;

            end
            wout(n).pix.pix_range = new_pix_range;
            wout(n).pix = wout(n).pix.finish_dump();

        else
            wout(n).pix = win(n).pix.get_pix_in_ranges(bl_start,bl_size);
        end
    end
end

end
