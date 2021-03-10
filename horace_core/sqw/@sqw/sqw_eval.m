function wout = sqw_eval(win, sqwfunc, pars, varargin)
% Calculate sqw for a model scattering function
%
%   >> wout = sqw_eval(win, sqwfunc, p)
%   >> wout = sqw_eval(___, '-all')
%   >> wout = sqw_eval(___, 'all', true)
%   >> wout = sqw_eval(___, '-average')
%   >> wout = sqw_eval(___, 'average', true)
%
% Input:
% ------
%   win        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q, w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh, qk, ql, en, p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A, js, gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated spectral weight
%
%               More general form is:
%                   weight = sqwfunc (qh, qk, ql, en, p, c1, c2, ..)
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1, c2, ...   Other constant parameters e.g. file name for look-up
%                              table
%
%   pars       Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A, js, gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
% Optional flags:
% ---------------
%   'all'      Requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%
%   'average' Requests that the calculated sqw be computed for the
%              average values of h, k, l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%              Applies only to the case of sqw object with pixel information
%             - it is ignored if dnd type object.
%
% Note: all optional string input parameters can be truncated up to minal
%       difference between them e.g. routine would accept 'al' and
%       'av', 'ave', 'aver' etc....
%
%
% Output:
% -------
%   wout        Output dataset or array of datasets
%
[sqwfunc, pars, opts] = parse_arguments(sqwfunc, pars, varargin{:});

wout = copy(win);
if ~iscell(pars)
    pars = {pars};  % package parameters as a cell for convenience
end

for i = 1:numel(win)
    if is_sqw_type(win(i))   % determine if sqw or dnd type
        if ~opts.average
            while true
                qw = calculate_qw_pixels(wout(i));
                stmp = sqwfunc(qw{:}, pars{:});
                pix = wout(i).data.pix;
                pix.signal = stmp(:)';
                pix.variance = zeros(1, numel(stmp));

                if pix.has_more()
                    pix.advance();
                else
                    break;
                end
            end
            wout(i) = recompute_bin_data(wout(i));
        else
            % Get average h, k, l, e for the bin, compute sqw for that average,
            % and fill pixels with the average signal for the bin that contains
            % them
            pix_file_backed = ...
                wout(i).data.pix.base_page_size < wout(i).data.pix.num_pixels;

            if pix_file_backed
                pix = wout(i).data.pix;
                npix = wout(i).data.npix;
                [npix_chunks, idxs] = split_vector(npix(:), pix.base_page_size);
                pix_bin_ends = cumsum(npix(:));
                pix_bin_starts = pix_bin_ends - npix(:) + 1;
                for j = 1:numel(npix_chunks)
                    pix_starts = max(1, pix_bin_starts(idxs(1, j)));
                    pix_ends = pix_bin_ends(idxs(2, j));

                    pix_chunk = pix.get_pix_in_ranges(pix_starts, pix_ends);
                    w_tmp = wout(i);
                    w_tmp.data.pix = pix_chunk;
                    qw = calculate_qw_pixels(w_tmp);

                    w_tmp.data.npix = npix_chunks{j};
                    qw_ave = average_bin_data(w_tmp, qw);
                    qw_ave = cellfun(@(x) x(:), qw_ave, 'UniformOutput', false);

                    s_tmp = sqwfunc(qw_ave{:}, pars{:});
                    sig_tmp = repelem(s_tmp, npix_chunks{j});

                    wout(i).data.pix.set_data( ...
                        {'signal', 'variance'}, ...
                        vertcat(sig_tmp', zeros(1, numel(sig_tmp))), ...
                        pix_starts:pix_ends ...
                    );
                end
                wout(i) = recompute_bin_data(wout(i));
            else
                qw = calculate_qw_pixels(win(i));
                qw_ave = average_bin_data(win(i), qw);
                qw_ave = cellfun(@(x)(x(:)), qw_ave, 'UniformOutput', false);
                stmp = sqwfunc(qw_ave{:}, pars{:});
                stmp = replicate_array(stmp, win(i).data.npix);
                wout(i).data.pix.signal = stmp(:)';
                wout(i).data.pix.variance = zeros(1, numel(stmp));
                wout(i) = recompute_bin_data(wout(i));
            end
        end

    else
        qw = calculate_qw_bins(win(i));
        if ~opts.all                    % only evaluate at the bins actually containing data
            ok = (win(i).data.npix ~= 0);   % should be faster than isfinite(1./win.data.npix), as we know that npix is zero or finite
            for idim = 1:4
                qw{idim} = qw{idim}(ok);  % pick out only the points where there is data
            end
            wout(i).data.s(ok) = sqwfunc(qw{:}, pars{:});
        else
            wout(i).data.s = reshape(sqwfunc(qw{:}, pars{:}), size(win(i).data.s));
        end
        wout(i).data.e = zeros(size(win(i).data.e));
    end
end

end


% -----------------------------------------------------------------------------
function [sqwfunc, pars, opts] = parse_arguments(sqwfunc, pars, varargin)
% Parse arguments for sqw_eval
flags = {'-all', '-average'};
[~, ~, all_flag, ave_flag, args] = parse_char_options(varargin, flags);

parser = inputParser();
parser.addRequired('sqwfunc', @(x) isa(x, 'function_handle'));
parser.addRequired('pars');
parser.addParameter('average', ave_flag, @islognumscalar);
parser.addParameter('all', all_flag, @islognumscalar);
parser.parse(sqwfunc, pars, args{:});
opts = parser.Results;

end
