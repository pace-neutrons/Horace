function [obj, data] = apply(obj, func_handle, args, data)
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
%        N.B. `args` are the same for each function
%
%   args
%        cell-array of extra args to pass to `func_handle`
%
%   data
%        DnD object whose data are to be recomputed according to the
%        result of `func_handle(obj,...)`

    if ~exist('args', 'var') || isempty(args)
        args = {{}};
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

    for i = 1:numel(func_handle)
        obj = func_handle{i}(obj, args{i}{:});
    end

    obj = obj.reset_changed_coord_range({'all'});

    if exist('data', 'var')
        [data.s, data.e] = obj.compute_bin_data(data.npix);
    end

end
