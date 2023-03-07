function obj = binary_op_double_(obj, double_array, binary_op, flip, npix)
%% BINARY_OP_DOUBLE_ perform a binary operation between this PixelData object
% and an array
%
validate_input_array(obj, double_array, npix);

obj.move_to_first_page();

if isempty(npix)
    obj = do_op_with_no_npix(obj, double_array, binary_op, flip);
else
    obj = do_op_with_npix(obj, double_array, binary_op, flip, npix);
end

end  % function


% -----------------------------------------------------------------------------
function obj = do_op_with_no_npix(obj, double_array, binary_op, flip)
% Perform the given binary operation between the given double array and
% PixelData object with no npix array.
% The double array must have length equal to the number of pixels.
%

for i = 1:obj.n_pages
    obj.page_num = i;
    pix_sigvar = sigvar(obj.signal, obj.variance);

    [start_idx, end_idx] = obj.get_page_idx_(i);

    double_sigvar = double_array(start_idx:end_idx);     % TGP 2021-04-11: to work with new classdef sigvar
    [obj.signal, obj.variance] = ...
        sigvar_binary_op_(pix_sigvar, double_sigvar, binary_op, flip);

end

end

function obj = do_op_with_npix(obj, double_array, binary_op, flip, npix)
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
% Re  #928 fix this
%fid = obj.get_new_handle();

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);
for i = 1:obj.n_pages
    obj.page_num = i;
    npix_for_page = npix_chunks{i};
    idx = idxs(:, i);

    sig_chunk = repelem(double_array(idx(1):idx(2)), npix_for_page)';

    this_sigvar = sigvar(obj.signal, obj.variance);
    %double_sigvar = sigvar(sig_chunk', []);
    double_sigvar = sig_chunk';     % TGP 2021-04-11: to work with new classdef sigvar
    [obj.signal, obj.variance] = ...
        sigvar_binary_op_(this_sigvar, double_sigvar, binary_op, flip);
% Re  #928 fix this
%    obj.format_dump_data(fid);
end
% Re  #928 fix this
%obj.finalise(fid);

end

function validate_input_array(obj, double_array, npix)
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
    num_pix = sum(npix(:));
    if num_pix ~= obj.num_pixels
        error( ...
            'PIXELDATA:binary_op_double_', ...
            ['Cannot perform binary operation. Sum of ''npix'' must be ' ...
             'equal to the number of pixels in the PixelData object.\n' ...
             'Found ''%i'' pixels in npix but ''%i'' in PixelData.'], ...
            num_pix, obj.num_pixels);
    end
end
end
