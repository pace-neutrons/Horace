function wout = shift_pixels (win, dispreln, pars, opt)
% Shift the energy of pixels in an sqw object according to a dispersion relation
%
%   >> wout = shift_pixels (win, dispreln, pars)
%
% Input:
% ------
%   win         Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   dispreln    Handle to function that calculates the dispersion relation w(Q)
%              Must have the form:
%                   w = dispreln (qh,qk,ql,p)
%               where
%                 Input:
%                   qh,qk,ql    Arrays containing the coordinates of a set
%                              of points in reciprocal lattice units
%                   p           Vector of parameters needed by the function
%                              e.g. [A,js,gam] as intensity, exchange, lifetime
%                 Output:
%                   w           Array of corresponding energies, or, if more than
%                              one dispersion relation, a cell array of arrays.
%
%              More general form is:
%                   w = dispreln (qh,qk,ql,p,c1,c2,..)
%                 where
%                   p           Typically a vector of parameters that we might
%                              want to fit in a least-squares algorithm
%                   c1,c2,...   Other constant parameters e.g. file name of
%                              a look-up table.
%
%   pars        Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
%   '-ave'       [option] Requests that the calculated sqw be computed for the
%              average values of h,k,l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%               Applies only to the case of sqw object with pixel information - it is
%              ignored if dnd type object.
%
% Output:
% -------
%   wout        Output dataset or array of datasets


% Check optional argument
ave_pix=false;
if exist('opt','var')  % no option given
    if ischar(opt) && ~isempty(strncmpi(opt,'-ave',numel(opt)))    % option 'ave' given
        ave_pix=true;
    else
        error('Unrecognised option')
    end
end

wout = copy(win);

if ~iscell(pars)
    pars={pars}; % package parameters as a cell for convenience
end

if ~all(arrayfun(@has_pixels, win))
    error('HORACE:sqw:not_implemented', ...
          'Not yet implemented for dnd objects')
end

for i=1:numel(win)
    % Get average h,k,l,e for the bin, compute sqw for that average,
    % and fill pixels with the average signal for the bin that contains them
    if win(i).pix.is_filebacked
        wout(i) = calc_shift_filebacked(win(i), dispreln, ave_pix, pars);
    else
        wout(i) = calc_shift_memory(win(i), dispreln, ave_pix, pars);
    end
    wout.pix = wout.pix.recalc_data_range('dE');

    % Have shifted the energy, but need to recompute the bins.
    % - If energy is a plot axis, then extend the range of the
    %   axis to retain all pixels.
    % - If energy is an integration axis, then pixels fall out if
    %   shifted outside the integration range (i.e. we don't extend
    %   the integration range)

    [proj, pbin] = get_proj_and_pbin(win(i));

    % Convert wout(i) into a single bin object
    pix  = wout(i).pix;
    new_data = d0d();
    new_data.axes.img_range = wout(i).data.axes.img_range;
    new_data.proj = wout.data.proj;

    new_data.npix = pix.num_pixels;

    new_data.axes.img_range(:,4) = pix.data_range(:,4);
    eps_lo = pix.data_range(1,4);
    eps_hi = pix.data_range(2,4);

    wout(i).data = new_data;

    pbin_i = pbin{i};
    % Redefine energy binning ranges with energy bin limits extended, if necessary
    if numel(pbin_i{4})==2
        pbin_i{4}(1) = floor(eps_lo);
        pbin_i{4}(2) = ceil(eps_hi);
    else
        de = pbin_i{4}(2);
        elo = floor(eps_lo)-0.5*de;
        ehi = ceil(eps_hi)+0.5*de;
        pbin_i{4} = [elo,de,ehi];
    end

end


end

function wout = calc_shift_memory(win, dispreln, ave_pix, pars)
    wout = win;
    qw = calculate_qw_pixels(win);
    if ~ave_pix
        qw = win.average_bin_data_(qw);
    end

    wdisp = dispreln(qw{1:3}, pars{:});

    if iscell(wdisp)
        wdisp = wdisp{1};     % pick out the first dispersion relation
    end

    wdisp = replicate_array(wdisp, win.data.npix);
    wout.pix.dE = win.pix.dE - wdisp(:)';
end

function wout = calc_shift_filebacked(win, dispreln, ave_pix, pars)
    wout = win;
    wout = wout.get_new_handle();

    e_ind = wout.pix.check_pixel_fields('dE');

    pg_size = get(hor_config, 'mem_chunk_size');

    [npix_chunks, idxs] = split_vector_fixed_sum(wout.data.npix(:), pg_size);

    wout.pix.data_range = PixelDataBase.EMPTY_RANGE;

    npg = wout.pix.num_pages
    for i = 1:npg
        wout.pix.page_num = i;

        npix_chunk = npix_chunks{i};
        qw = calculate_qw_pixels(wout);

        if ~ave_pix
            qw = average_bin_data(npix_chunk, qw);
        end

        wdisp=dispreln(qw{1:3}, pars{:});
        if iscell(wdisp)
            wdisp=wdisp{1};     % pick out the first dispersion relation
        end

        wdisp = replicate_array(wdisp, npix_chunk);
        wout.pix.dE = wout.pix.dE - wdisp(:)';
        wout.pix = wout.pix.reset_changed_coord_range('all');

        pix.format_dump_data(data);
    end

    wout.pix = pix.finalise();
end
