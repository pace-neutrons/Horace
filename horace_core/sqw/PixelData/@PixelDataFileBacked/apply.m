function [obj, data] = apply(obj, func_handle, args, data, compute_variance)
% Apply a function (`func_handle`) to pixels (`obj`) with extra arguments `args`
%  and recomputes the DnD if provided in `data`
%
% Inputs:
%
%   obj
%        PixelDataFileBacked object
%
%   func_handle
%        Function handle or cell array of function handles to apply
%        `func_handle` must have a signature corresponding to:
%
%        pix_obj = func_handle(pix_obj, args{1}, ..., args{N})
%
%   args
%        cell-array of extra args to pass to `func_handle`
%        args can either be a cell array of args for all func_handles
%        or a cell-array of cell-arrays matching the length of func_handles
%        to provide args to each function
%
%   data
%        DnD object whose data are to be recomputed according to the
%        result of `func_handle(obj,...)`


    if ~exist('args', 'var') || isempty(args)
        args = {{}};
    end

    if ~exist('compute_variance', 'var')
        compute_variance = false;
    end

    if ~iscell(args)
        args = {{args}};
    end

    if isa(func_handle, 'function_handle')
        func_handle = {func_handle};
    end

    if numel(args) == 1
        args = repmat(args, numel(func_handle), 1);
    elseif numel(args) ~= numel(func_handle)
        error('HORACE:apply:invalid_argument', ...
              'Number of arguments does not match number of function handles')
    end

    if exist('data', 'var')
        [obj, data] = apply_op_dnd(obj, func_handle, args, data, compute_variance);
    else
        obj = apply_op_no_dnd(obj, func_handle, args);
    end
end

function [obj, data] = apply_op_dnd(obj, func_handle, args, data, compute_variance)

    ll = config_store.instance().get_value('hor_config', 'log_level');

    obj = obj.prepare_dump();

    mem_chunk_size = config_store.instance().get_value('hor_config', 'mem_chunk_size');
    [chunks, indices] = split_vector_max_sum(data.npix(:), mem_chunk_size);

    pix = 1;
    obj.data_range = PixelDataBase.EMPTY_RANGE;
    for i = 1:numel(chunks)
        npix = sum(chunks{i});

        if ll > 0 && mod(i, 10) == 1
            fprintf('Processing page %d/%d', i, numel(chunks));
        end

        curr_pix = obj.get_pixels(pix:pix+npix-1, '-ignore_range');
        for j = 1:numel(func_handle)
            curr_pix = func_handle{j}(curr_pix, args{j}{:});
        end

        if compute_variance
            [data.s(indices(1, i):indices(2, i)), ...
             data.e(indices(1, i):indices(2, i)), ...
             curr_pix.variance] = average_bin_data(chunks{i}, curr_pix.signal);
        else
            [data.s(indices(1, i):indices(2, i)), ...
             data.e(indices(1, i):indices(2, i))] = compute_bin_data(curr_pix, chunks{i});
        end

        obj.data_range = ...
            obj.pix_minmax_ranges(curr_pix.data, obj.data_range);

        obj = obj.format_dump_data(curr_pix.data);

        pix = pix + npix;
    end

    obj = obj.finish_dump();

end

function obj = apply_op_no_dnd(obj, func_handle, args)

    ll = config_store.instance().get_value('hor_config', 'log_level');

    obj = obj.prepare_dump();

    n_pages = obj.num_pages;
    obj.data_range = PixelDataBase.EMPTY_RANGE;

    for i = 1:n_pages
        if ll > 0 && mod(i, 10) == 1
            fprintf('Processing page %d/%d', i, n_pages);
        end

        [start_idx, end_idx] = obj.get_page_idx_(i);

        curr_pix = obj.get_pixels(start_idx:end_idx, '-ignore_range');

        for j = 1:numel(func_handle)
            curr_pix = func_handle{j}(curr_pix, args{j}{:});
        end

        obj.data_range = curr_pix.pix_minmax_ranges(curr_pix.data, obj.data_range);

        obj = obj.format_dump_data(curr_pix.data);
    end

    obj = obj.finish_dump();

end
