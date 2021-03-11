function obj = binary_op_double_(obj, double_array, binary_op, flip, npix)
%% BINARY_OP_DOUBLE_ perform a binary operation between this PixelData object
% and an array
%
npix_cum_sum = validate_input_array(obj, double_array, npix);

obj.move_to_first_page();

if isempty(npix)
    obj = do_op_with_no_npix(obj, double_array, binary_op, flip);
else
    obj = do_op_with_npix(obj, double_array, binary_op, flip, npix, npix_cum_sum);
end

end  % function


% -----------------------------------------------------------------------------
function obj = do_op_with_no_npix(obj, double_array, binary_op, flip)
    % Perform the given binary operation between the given double array and
    % PixelData object with no npix array.
    % The double array must have length equal to the number of pixels.
    %
    base_page_size = obj.page_size;
    while true

        pix_sigvar = sigvar(obj.signal, obj.variance);

        start_idx = (obj.page_number_ - 1)*base_page_size + 1;
        end_idx = min(start_idx + base_page_size - 1, obj.num_pixels);

        double_sigvar = sigvar(double_array(start_idx:end_idx), []);
        [obj.signal, obj.variance] = ...
                sigvar_binary_op_(pix_sigvar, double_sigvar, binary_op, flip);

        if obj.has_more()
            obj.advance();
        else
            break;
        end
    end
end


function obj = do_op_with_npix(obj, double_array, binary_op, flip, npix, npix_cum_sum)
    % Perform the given binary op between the given PixelData object and the
    % given double array replicated uses npix.
    % An example operation with the "plus" operator is given below:
    %   obj.signal                  = [1, 3, 5, 6, 2, 7, 4, 6]
    %   double_array                = [2,       1,    4]
    %   npix                        = [3,       2,    3]
    %    -> replicated_double_array = [2, 2, 2, 1, 1, 4, 4, 4]
    %       result.signal = replicated_double_array + obj.signal
    %                     = [3, 5, 7, 7, 3, 11, 8, 10]
    %
    % The operation is performed whilst looping over the pages in the PixelData
    % object.
    %
    [npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size, npix_cum_sum);
    page_number = 1;
    while true
        npix_for_page = npix_chunks{page_number};
        idx = idxs(:, page_number);

        sig_chunk = repelem(double_array(idx(1):idx(2)), npix_for_page)';

        this_sigvar = sigvar(obj.signal, obj.variance);
        double_sigvar = sigvar(sig_chunk', []);
        [obj.signal, obj.variance] = ...
            sigvar_binary_op_(this_sigvar, double_sigvar, binary_op, flip);

        if obj.has_more()
            obj.advance();
        else
            break;
        end

    end
end


function npix_cum_sum = validate_input_array(obj, double_array, npix)
    if ~isequal(size(double_array), [1, obj.num_pixels]) && isempty(npix)
        required_size = sprintf('[1 %i]', obj.num_pixels);
        actual_size = num2str(size(double_array));
        error('PIXELDATA:do_binary_op', ...
              ['Cannot perform binary operation. Double array must ' ...
               'have size equal to number of pixels.\nFound size ''[%s]'', ' ...
               '''[%s]'' required.'], actual_size, required_size);
    elseif ~isempty(npix)
        % Get the cumsum rather than just the sum here since it's required in
        % do_op_with_npix
        npix_cum_sum = cumsum(npix(:));
        if npix_cum_sum(end) ~= obj.num_pixels
            error('PIXELDATA:binary_op_double_', ...
                ['Cannot perform binary operation. Sum of ''npix'' must be ' ...
                'equal to the number of pixels in the PixelData object.\n' ...
                'Found ''%i'' pixels in npix but ''%i'' in PixelData.'], ...
                npix_cum_sum(end), obj.num_pixels);
        end
    else
        npix_cum_sum = [];
    end
end
