function pix_out = mask(obj, mask_array, npix)
%% MASK remove the pixels specified by the input logical array
%
% You must specify exactly one return argument when calling this function.
%
% Input:
% ------
% mask_array   A logical array specifying which pixels should be kept/removed
%              from the PixelData object. Must be of length equal to the number
%              of pixels in 'obj' or equal in size to the 'npix' argument. A
%              true/1 in the array indicates that the pixel at that index
%              should be retained, a false/0 indicates the pixel should be
%              removed.
%
% npix         Array of integers that specify how many times each value in
%              mask_array should be replicated. This is useful for when masking
%              all pixels contributing to a bin. Size must be equal to that of
%              'mask_array'. E.g.:
%               mask_array = [      0,     1,     1,  0,     1]
%               npix       = [      3,     2,     2,  1,     2]
%               full_mask  = [0, 0, 0,  1, 1,  1, 1,  0,  1, 1]
%
%              The npix array must account for all pixels in the PixelData
%              object i.e. sum(npix, 'all') == obj.num_pixels. It must also be
%              the same dimensions as 'mask_array' i.e.
%              all(size(mask_array) == size(npix)).
%
if nargout ~= 1
    error('PIXELDATA:mask', ['Bad number of output arguments.\n''mask'' must be ' ...
                             'called with exactly one output argument.']);
else
    if exist('npix', 'var')
        validate_input_args(obj, mask_array, npix);
    else
        validate_input_args(obj, mask_array);
    end
end

if numel(mask_array) == obj.num_pixels && all(mask_array)
    pix_out = obj;
    return;
elseif numel(mask_array) == obj.num_pixels && ~any(mask_array)
    pix_out = PixelData();
    return;
end

if ~isvector(npix)
    npix = npix(:);
end
if ~isvector(mask_array)
    mask_array = logical(mask_array(:));
end

if ~isa(mask_array, 'logical')
    mask_array = logical(mask_array);
end

if numel(mask_array) == obj.num_pixels

    if obj.is_file_backed_()
        pix_out = do_mask_file_backed_with_full_mask_array(obj, mask_array);
    else
        pix_out = obj.get_pixels(mask_array);
    end

elseif exist('npix', 'var')

    if obj.is_file_backed_()
        pix_out = do_mask_file_backed_with_npix(obj, mask_array, npix);
    else
        full_mask_array = repelem(mask_array, npix);
        pix_out = do_mask_in_memory_with_full_mask_array(obj, full_mask_array);
    end

end

end


% -----------------------------------------------------------------------------
function pix_out = do_mask_in_memory_with_full_mask_array(obj, mask_array)
    % Perform a mask of an all in-memory PixelData object with a mask array as
    % long as the PixelData array i.e. numel(mask_array) == pix.num_pixels
    %
    pix_out = obj.get_pixels(mask_array);
end

function pix_out = do_mask_file_backed_with_full_mask_array(obj, mask_array)
    % Perfrom a mask of a file-backed PixelData object with a mask array as
    % long as the full PixelData array i.e. numel(mask_array) == pix.num_pixels
    %
    obj.move_to_first_page();

    pix_out = PixelData();
    end_idx = 0;
    while true
        start_idx = end_idx + 1;
        end_idx = start_idx + obj.page_size - 1;
        mask_array_chunk = mask_array(start_idx:end_idx);

        pix_out.append(obj.get_pixels(mask_array_chunk));

        if obj.has_more()
            obj = obj.advance();
        else
            break;
        end
    end
end

function pix_out = do_mask_file_backed_with_npix(obj, mask_array, npix)
    % Perform a mask of a file-backed PixelData object with a mask array and
    % an npix array. The npix array should account for the full range of pixels
    % in the PixelData instance i.e. sum(npix) == pix.num_pixels.
    %
    % The mask_array and npix array should have equal dimensions.
    %
    obj.move_to_first_page();
    pix_out = PixelData();

    end_idx = 1;
    npix_cum_sum = cumsum(npix(:));
    while true
        start_idx = (end_idx - 1) + find(npix_cum_sum(end_idx:end) > 0, 1);
        leftover_begin = npix_cum_sum(start_idx);
        npix_cum_sum = npix_cum_sum - obj.page_size;
        end_idx = (start_idx - 1) + find(npix_cum_sum(start_idx:end) > 0, 1);
        if isempty(end_idx)
            end_idx = numel(npix);
        end

        if start_idx == end_idx
            % All pixels in page
            if ~exist('leftover_end', 'var')
                leftover_end = 0;
            end
            npix_chunk = min(obj.page_size, npix(start_idx) - leftover_end);
        else
            % Leftover_end = number of pixels to allocate to final bin n,
            % there will be more pixels to allocate to bin n in the next iteration
            leftover_end = ...
                obj.page_size - (leftover_begin + sum(npix(start_idx + 1:end_idx - 1)));
            npix_chunk = npix(start_idx + 1:end_idx - 1);
            npix_chunk = [leftover_begin, npix_chunk(:).', leftover_end];
        end

        mask_array_chunk = repelem(mask_array(start_idx:end_idx), npix_chunk);

        pix_out.append(obj.get_pixels(mask_array_chunk));

        if obj.has_more()
            obj.advance();
        else
            break;
        end
    end
end

function validate_input_args(obj, mask_array, npix)
    if nargin == 2 && numel(mask_array) ~= obj.num_pixels
        error('PIXELDATA:mask', ...
            ['Error masking pixel data.\nThe input mask_array must have ' ...
            'number of elements equal to the number of pixels or must be ' ...
            'accompanied by the npix argument. Found ''%i'' elements, ''%i'' or '...
            '''%i'' elements required.'], numel(mask_array), obj.num_pixels, ...
            obj.page_size);
    elseif nargin == 3
        if any(size(npix) ~= size(mask_array))
            error('PIXELDATA:mask', 'Size of mask_array and npix must be equal.');
        elseif sum(npix, 'all') ~= obj.num_pixels
            error('PIXELDATA:mask', ...
                ['The sum of npix must be equal to number of pixels.\n' ...
                'Found sum(npix) = %i, %i pixels required.'], ...
                sum(npix, 'all'), obj.num_pixels);
        end
    end
end
