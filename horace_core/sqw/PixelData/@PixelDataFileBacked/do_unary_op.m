function [pix_out, data] = do_unary_op(obj, unary_op, data)
% Perform a unary operation on this object's signal and variance arrays
%
% Input:
% -----
% unary_op   Function handle pointing to the operation to perform. This
%            operation should take a sigvar object as an argument.
%
% data       dnd object containing npix information

pix_out = obj;

pix_out = pix_out.prepare_dump();

if exist('data', 'var')
    [pix_out, data] = unary_op_dnd(pix_out, unary_op, data);
else
    pix_out = unary_op_no_dnd(pix_out, unary_op);
    data = [];
end

end

function [pix_out, data] = unary_op_dnd(pix_out, unary_op, data)

    pix_out = pix_out.prepare_dump();

    mem_chunk_size = config_store.instance().get_value('hor_config', 'mem_chunk_size');
    [chunks, indices] = split_vector_max_sum(data.npix(:), mem_chunk_size);

    pix = 1;
    pix_out.data_range = PixelDataBase.EMPTY_RANGE;
    for i = 1:numel(chunks)

        npix = sum(chunks(i));

        curr_pix = pix_out.get_pixels(pix:pix+npix, '-ignore_range');

        pix_sigvar = sigvar(curr_pix.signal, curr_pix.variance);
        pg_result  = unary_op(pix_sigvar);

        curr_pix.signal = pg_result.s;
        curr_pix.variance = pg_result.e;

        [data.s(indices(1, i):indices(2, i)), ...
         data.e(indices(1, i):indices(2, i))] = compute_bin_data(curr_pix, chunks(i));%average_bin_data(chunks(i), curr_pix.signal);

        pix_out.data_range = ...
            pix_out.pix_minmax_ranges(curr_pix.data, pix_out.data_range);

        pix_out.format_dump_data(curr_pix.data);

        pix = pix + npix;
    end

    pix_out.finalise();

end

function pix_out = unary_op_no_dnd(pix_out, unary_op)

    pix_out = pix_out.prepare_dump();
    s_ind = pix_out.check_pixel_fields('signal');
    v_ind = pix_out.check_pixel_fields('variance');

    n_pages = pix_out.num_pages;
    pix_out.data_range = PixelDataBase.EMPTY_RANGE;

    for i = 1:n_pages
        pix_out.page_num = i;
        data = pix_out.data;

        pix_sigvar = sigvar(data(s_ind,:), data(v_ind,:));
        pg_result  = unary_op(pix_sigvar);

        data(s_ind, :) = pg_result.s;
        data(v_ind, :) = pg_result.e;
        pix_out.data_range = ...
            pix_out.pix_minmax_ranges(data, pix_out.data_range);

        pix_out.format_dump_data(data);
    end

    pix_out = pix_out.finish_dump();

end
