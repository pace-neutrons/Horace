function obj = binary_op_double_(obj, double_array, binary_op, flip, npix)
%% BINARY_OP_DOUBLE_ perform a binary operation between this PixelData object
% and an array
%
validate_input_array(obj, double_array, npix);

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

obj = obj.prepare_dump();

sv_ind = obj.get_pixfld_indexes('sig_var');
obj.data_range = PixelDataBase.EMPTY_RANGE;
% TODO: #975 loop have to be moved level up calculating image too in single
% loop
num_pages= obj.num_pages;
pix_sigvar = sigvar();
for i = 1:num_pages
    obj.page_num = i;
    data = obj.data;
    pix_sigvar.sig_var = data(sv_ind,:);

    [start_idx, end_idx] = obj.get_page_idx_(i);
    %TODO: This is probably incorrect as data are within the pages and what
    %is indexes are global
    double_sigvar = double_array(start_idx:end_idx);     % TGP 2021-04-11: to work with new classdef sigvar

    sig_var = ...
        obj.sigvar_binary_op(pix_sigvar, double_sigvar, binary_op, flip);

    data(sv_ind, :) = sig_var;

    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range);

    obj = obj.format_dump_data(data);

end

obj = obj.finish_dump();

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

obj = obj.prepare_dump();
sv_ind = obj.get_pixfld_indexes('sig_var');
obj.data_range = PixelDataBase.EMPTY_RANGE;
%
% TODO: #975 loop have to be moved level up calculating image in single
% loop too

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);
num_pages= obj.num_pages;
pix_sigvar = sigvar();

for i = 1:num_pages
    obj.page_num = i;
    data = obj.data;

    npix_for_page = npix_chunks{i};
    idx = idxs(:, i);

    sig_chunk = repelem(double_array(idx(1):idx(2)), npix_for_page)';

    pix_sigvar.sig_var  = obj.sig_var;
    %double_sigvar = sigvar(sig_chunk', []);
    double_sigvar = sig_chunk';     % TGP 2021-04-11: to work with new classdef sigvar

    sig_var = ...
        sigvar_binary_op_(pix_sigvar, double_sigvar, binary_op, flip);

    data(sv_ind, :) = sig_var;


    obj = obj.format_dump_data(data);

    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range);
end

obj = obj.finish_dump();
end

function validate_input_array(obj, double_array, npix)

expected_size = [1, obj.num_pixels];
passed_size = size(double_array);

if ~isequal(passed_size, expected_size) && isempty(npix)
    required_size = mat2str(expected_size);
    actual_size = mat2str(passed_size);
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        ['Cannot perform binary operation. Double array must ' ...
        'have size equal to number of pixels.\nFound size , ' ...
        '%s required.'], actual_size, required_size);

elseif ~isempty(npix)
    % Get the cumsum rather than just the sum here since it's required in
    % do_op_with_npix
    num_pix = sum(npix(:));
    if num_pix ~= obj.num_pixels
        error( ...
            'HORACE:PixelDataFileBacked:invalid_argument', ...
            ['Cannot perform binary operation. Sum of ''npix'' must be ' ...
            'equal to the number of pixels in the PixelData object.\n' ...
            'Found ''%i'' pixels in npix but ''%i'' in PixelData.'], ...
            num_pix, obj.num_pixels);
    end
end

end
