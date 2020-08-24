function pix_out = mask(obj, mask_array, npix)
%% MASK remove the pixels specified by the input logical array
%
% Input:
% ------
% mask_array   A logical array specifying which pixels should be kept/removed
%              from the PixelData object; of length equal to the number of pixels in obj
%              or equal to the current page size of obj.
%
if nargout ~= 1
    error('PIXELDATA:mask', ['Bad number of output arguments.\n''mask'' must be' ...
                             'called with exactly one output argument.']);
end

if numel(mask_array) == obj.num_pixels && all(mask_array)
    pix_out = obj;
    return;
elseif numel(mask_array) == obj.num_pixels && ~any(mask_array)
    pix_out = PixelData();
    return;
end

if ~isa(mask_array, 'logical')
    mask_array = logical(mask_array);
end

if numel(mask_array) == obj.num_pixels
    if obj.is_file_backed_()
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
    else
        pix_out = obj.get_pixels(mask_array);
    end

else
    error('PIXELDATA:mask', ...
          ['Error masking pixel data.\nThe input mask_array must have ' ...
           'number of elements equal to the number of pixels or page size ' ...
           'of the PixelData object. Found ''%i'' elements, ''%i'' or '...
           '''%i'' elements required.'], numel(mask_array), obj.num_pixels, ...
           obj.page_size);
end
