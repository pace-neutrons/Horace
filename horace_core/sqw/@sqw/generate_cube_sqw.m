function out = generate_cube_sqw(shape)
% Generate a cube of evenly-spaced SQW data
%
% For even counts these are:
%   [-X/2 + 0.5 : 1 : X/2 - 0.5] i.e. for 2 -> [-0.5 0.5]
% For odd counts these are:
%   [-floor(X/2):floor(X/2)] i.e. for 3 -> [-1 0 1]
%
% FOR TESTING CUT/SYMMETRISE
% The data will be invalid in most circumstances and may
% result in errors or invalid results if used outside of
% cut/symmetrise
%
    out = sqw();

    if isscalar(shape) && isnumeric(shape)
        ndim = 4;
        npix = shape^ndim;
        pix_data = zeros(9, npix);


        if mod(shape, 2) == 0
            minloc = -shape/2 + 0.5;
            maxloc = shape/2 - 0.5;
        else
            minloc = -(shape-1)/2;
            maxloc = (shape-1)/2;
        end
        col = [minloc:1:maxloc];

        % Calculate cartesian product of positions to generate all grid points
        for dim = 1:ndim
            pix_data(dim, :) = repmat(repelem(col, shape^(dim-1)), 1, shape^(ndim-dim));
        end

        % Set run_idxs to 1 (needs to be ones to avoid conflicts with expdata)
        pix_data(5, :) = ones(1, npix);
        % set detector_idx, energy_idx, signal, variance to 1:npix
        pix_data(6:9, :) = repmat(1:npix, 4, 1);

    else
        error('HORACE:sqw:not_implemented', 'Currently no support for non-cube data')
    end

    pix = PixelDataMemory(pix_data);
    out.pix = pix;
    samp = IX_sample([1 1 1], [90 90 90]);
    expdata = struct( ...
        "filename", 'fake', ...
        "filepath", '/fake', ...
        "efix", 1, ...
        "emode", 1, ...
        "cu", 1, ...
        "cv", 1, ...
        "psi", 1, ...
        "omega", 1, ...
        "dpsi", 1, ...
        "gl", 1, ...
        "gs", 1, ...
        "en", 10, ...
        "uoffset", [0 0 0], ...
        "u_to_rlu", eye(3), ...
        "ulen", 1.0, ...
        "ulabel", 'rrr', ...
        "run_id", 1);

    out.experiment_info.samples = out.experiment_info.samples.add(samp);
    out.experiment_info.instruments = out.experiment_info.instruments.add(IX_null_inst());
    out.experiment_info.expdata = IX_experiment(expdata);

    out.data.axes = ortho_axes(...
        [-shape/2 shape/2], ...
        [-shape/2 shape/2], ...
        [-shape/2 shape/2], ...
        [-shape/2 shape/2]);
    out.data.npix = npix;

    out = cut(out, ortho_proj([1 0 0], [0 1 0]), ...
              [minloc 1 maxloc], ...
              [minloc 1 maxloc], ...
              [minloc 1 maxloc], ...
              [minloc 1 maxloc]);

end