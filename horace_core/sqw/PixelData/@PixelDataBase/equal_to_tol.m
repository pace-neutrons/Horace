function [ok, mess] = equal_to_tol(obj, other_pix, varargin)
%% EQUAL_TO_TOL Check if two PixelData objects are equal to a given tolerance
%
% Input:
% ------
% pix        The first pixel data object to compare.
%
% other_pix  The second pixel data object to compare.
%
% tol        Tolerance criterion for numeric arrays
%            (default = [0, 0] i.e. equality)
%            It has the form: [abs_tol, rel_tol] where
%               abs_tol     absolute tolerance (>=0; if =0 equality required)
%               rel_tol     relative tolerance (>=0; if =0 equality required)
%            If either criterion is satisfied then equality within tolerance
%            is accepted.
%             Examples:
%               [1e-4, 1e-6]    absolute 1e-4 or relative 1e-6 required
%               [1e-4, 0]       absolute 1e-4 required
%               [0, 1e-6]       relative 1e-6 required
%               [0, 0]          equality required
%               0               equivalent to [0,0]
%
%            A scalar tolerance can be given where the sign determines if
%            the tolerance is absolute or relative:
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%            Examples:
%               1e-4            absolute tolerance, equivalent to [1e-4, 0]
%               -1e-6           relative tolerance, equivalent to [0, 1e-6]
%
% Keyword Input:
% ---------------
% nan_equal  Treat NaNs as equal (true or false; default=true).
%
% name_a     Explicit name of variable a for use in messages
%            Usually not required, as the name of a variable will
%            be discovered. However, if the input argument is an array
%            element e.g. my_variable{3}  then the name is not
%            discoverable in Matlab, and default 'input_1' will be
%            used unless a different value is given with the keyword 'name_a'.
%            (default = 'input_1').
%
% name_b     Explicit name of variable b for use in messages.
%            The same comments apply as for 'name_a' except the default is
%            'input_2'.
%            (default = 'input_2').
%

[opt, argi] = parse_args(varargin{:});


[ok, mess] = validate_other_pix(obj, other_pix);
if ~ok
    return
end

if ~opt.reorder && opt.fraction == 1
    [ok, mess] = compare_raw(obj, other_pix, argi);
elseif opt.fraction ~= 1
    [ok, mess] = compare_frac(obj, other_pix, opt.fraction, argi);
else
    [ok, mess] = compare_reorder(obj, other_pix, opt, argi)
end

end

end

function [ok, mess] = compare_raw(obj, other_pix, argi)
    is_fb = [obj.is_filebacked, other_pix.is_filebacked];

    if all(is_fb)

        for i = 1:obj.num_pages
            obj.page_num = i;
            other_pix.page_num = i;

            [ok, mess] = equal_to_tol(obj.data, other_pix.data, argi{:});
            if ~ok
                break;
            end
        end

    elseif any(is_fb)
        if is_fb(1)
            fb = obj;
            other = other_pix;
        else
            fb = other_pix;
            other = obj;
        end

        for i = 1:fb.num_pages
            fb.page_num = i;

            [start_idx, end_idx] = fb.get_page_idx_();
            [ok, mess] = equal_to_tol(fb.data, other.data(:, start_idx:end_idx), argi{:});

            if ~ok
                break;
            end

        end

    else
        [ok, mess] = equal_to_tol(obj.data, other_pix.data, argi{:});
    end
end

function [ok, mess] = compare_frac(obj, other_pix, frac, argi)

    compare_spacing = floor(1 / opt.fraction);
    compare_count = num_pixels * opt.fraction;
    chunk_size = get(hor_config, 'mem_chunk_size');

    for i = 1:chunk_size:compare_count
        range = round(i:compare_spacing:i+chunk_size);
        candidate_a = get_data(obj, range);
        candidate_b = get_data(other_pix, range);
        [ok, mess] = equal_to_tol(candidate_a, candidate_b, argi{:});

        if ~ok
            break;
        end
    end

end

function [ok, mess] = compare_reorder(obj, other_pix, opt, argi)

    if isempty(opt.npix)
        error('HORACE:equal_to_tol:invalid_argument', ...
              'Requested pixel reorder, did not provide npix')
    end

    if sum(npix) ~= obj.num_pixels
        error('HORACE:equal_to_tol:invalid_argument', ...
              'Given npix array does not match number of pixels')
    end

    compare_spacing = floor(1 / opt.fraction);
    chunk_size = get(hor_config, 'mem_chunk_size');

    nend = cumsum(opt.npix);

    compare_count = numel(ibin);

    prev = 0;
    points = [0:chunk_size:compare_count, compare_count+1];

    for i = numel(points)

        curr = find(nend > points(i+1), 1);

        if nend(curr - 1) == points(i+1)  % Falls on bin boundary
            curr = curr - 1;
        elseif isempty(curr)             % Falls after end of array
            curr = numel(nend);
        end

        curr_ipix = points(i)+1:compare_spacing:points(i+1);

        sort_by = {'run_idx', 'detector_idx', 'energy_idx'};
        s1 = pix1.get_pixels(curr_ipix);
        [~, ix] = sortrows([ibinarr, s1.get_fields(sort_by)']);
        s1 = s1.get_pixels(ix);

        s2 = pix2.get_pixels(curr_ipix);
        [~, ix] = sortrows([ibinarr, pix2.get_fields(sort_by)']);
        s2 = s2.get_pixels(ix);

        % Now compare retained pixels
        [ok, mess] = equal_to_tol(s1, s2, argi{:});
        if ~ok
            break
        end
    end

end

function [ok, mess] = validate_other_pix(obj, other_pix)
    ok = true;
    mess = '';

    if ~isa(other_pix, 'PixelDataBase')
        ok = false;
        mess = sprintf('Objects of class ''%s'' and ''%s'' cannot be equal.', ...
                       class(obj), class(other_pix));
        return
    end

    if obj.num_pixels ~= other_pix.num_pixels
        ok = false;
        mess = sprintf(['PixelData objects are not equal. ' ...
                        'Argument 1 has %i pixels, argument 2 has %i'], ...
                       obj.num_pixels, other_pix.num_pixels);
        return
    end
end

function [opt, argi] = parse_args(varargin)
    parser = inputParser();
    parser.addOptional('tol', [0, 0], @(x) (numel(x) <= 2));
    parser.addParameter('nan_equal', true, @islognumscalar);
    parser.addParameter('name_a', 'input_1', @ischar);
    parser.addParameter('name_b', 'input_2', @ischar);
    parser.addParameter('reorder', true, @islognumscalar);
    parser.addParameter('npix', [], @isnumeric);
    parser.addParameter('fraction', 1, @(x) isnumeric(x) && x > 0 && x <= 1)
    parser.KeepUnmatched = true;  % ignore unmatched parameters
    parser.parse(varargin{:});

    opt = parser.Results;
    % Args for base equal_to_tol
    argi = {'tol', opt.tol, 'nan_equal', opt.nan_equal, 'name_a', opt.name_a, 'name_b', opt.name_b};
end
