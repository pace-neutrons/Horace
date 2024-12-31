function [ok, mess] = equal_to_tol_single(pix, other_pix, opt,varargin)
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
% reorder    Boolean testing whether the pixels should be reordered within bins
%            to ensure equality between pixels representing  equivalent DnD objects
%
% npix       Required if reorder is true to determine binning and permitted reorders
%
% fraction   Value between 0 and 1 which determines what fraction of pixels are
%            compared. E.g. for fraction 1/3 every 3rd pixel is compared.
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


% Empty pix equal, validate proves both empty
if pix.num_pixels == 0
    ok = true;
    mess = [];
    return;
end

if opt.reorder
    if isempty(opt.npix)
        opt.npix = pix.num_pixels; % presume pixels are not ordered so all
        % have to be compared
    end
    [ok, mess] = compare_reorder(pix, other_pix, opt,varargin{:});
elseif opt.fraction ~= 1
    [ok, mess] = compare_frac(pix, other_pix, opt,varargin{:});
else
    [ok, mess] = compare_raw(pix, other_pix, opt,varargin{:});
end

end

function [ok, mess] = compare_raw(pix, other_pix, opt,present)
is_fb = [pix.is_filebacked, other_pix.is_filebacked];

if all(is_fb)
    for i = 1:pix.num_pages
        pix.page_num = i;
        other_pix.page_num = i;

        [ok, mess] = equal_to_tol(pix.data, other_pix.data, opt,present);
        if ~ok
            [start_idx, end_idx] = pix.get_page_idx_();
            mess = process_message(mess, start_idx);
            break;
        end
    end
elseif any(is_fb)
    if is_fb(1)
        fb = pix;
        other = other_pix;
    else
        fb = other_pix;
        other = pix;
    end

    for i = 1:fb.num_pages
        fb.page_num = i;

        [start_idx, end_idx] = fb.get_page_idx_();
        [ok, mess] = equal_to_tol(fb.data, other.data(:, start_idx:end_idx), opt,present);

        if ~ok
            mess = process_message(mess, start_idx);
            break;
        end
    end

else
    [ok, mess] = equal_to_tol(pix.data, other_pix.data,opt,present);
    if ~ok

        mess = process_message(mess);
    end
end
end

function [ok, mess] = compare_frac(pix, other_pix, opt,present)

compare_spacing = floor(1 / opt.fraction);
%compare_count = pix.num_pixels * opt.fraction;
chunk_size = get(hor_config, 'mem_chunk_size')*compare_spacing;

for i = 1:chunk_size:pix.num_pixels
    lim = min(i+chunk_size, pix.num_pixels);
    range = round(i:compare_spacing:lim);
    candidate_a = pix.data(range);
    candidate_b = other_pix.data(range);
    [ok, mess] = equal_to_tol(candidate_a, candidate_b, opt,present);

    if ~ok
        mess = process_message(mess, i, compare_spacing);
        break;
    end
end

end

function [ok, mess] = compare_reorder(pix1, pix2, opt,present)
if ~isfield(opt,'npix') || isempty(opt.npix)
    error('HORACE:equal_to_tol:invalid_argument', ...
        'Requested pixel reorder, did not provide npix')
end
npix = opt.npix;
%
%     if sum(npix, 'all') ~= pix1.num_pixels
%         error('HORACE:equal_to_tol:invalid_argument', ...
%               'Given npix array does not match number of pixels')
%     end

% In case of reorder, fraction is relative to bins rather than pixels.
compare_spacing = floor(1 / opt.fraction);
mem_chunk_size = get(hor_config, 'mem_chunk_size');

bin_end = cumsum(npix);
bin_start = bin_end - npix + 1;

selected_bins = find(npix);
selected_bins = selected_bins(1:compare_spacing:end);

pix_ind = replicate_iarray(bin_start(selected_bins), npix(selected_bins)) + sawtooth_iarray(npix(selected_bins)) - 1;
bin_ind = replicate_iarray(selected_bins, npix(selected_bins)); % bin index for each retained pixel

for i = 1:mem_chunk_size:numel(pix_ind)
    curr_pix_ind = pix_ind(i:min(i+mem_chunk_size-1, numel(pix_ind)));
    curr_bin_ind = bin_ind(i:min(i+mem_chunk_size-1, numel(pix_ind)));


    s1 = pix1.get_pixels(curr_pix_ind);
    [~, ix1] = sortrows([curr_bin_ind, s1.all_indexes']);
    s1 = s1.data(:,ix1);

    s2 = pix2.get_pixels(curr_pix_ind);
    [~, ix2] = sortrows([curr_bin_ind, s2.all_indexes']);
    s2 = s2.data(:,ix2);

    % Now compare retained pixels
    [ok, mess] = equal_to_tol(s1, s2, opt,present);
    if ~ok
        mess = process_message(mess, i, compare_spacing, ix1, ix2);
        return;
    end
end

end


function mess = process_message(mess, offset, spacing, ix1, ix2)
% Reprocess error message to give accurate pixel numbers and column name
[match, str] = regexp(mess, 'element \((\d+)\)', 'tokens', 'split');
if isempty(match)
    return;
end

if ~exist('spacing', 'var')
    spacing = 1;
end
if ~exist('offset', 'var')
    offset = 0;
end

ind = str2num(match{1}{1});

pix = floor(ind / 9)+1;
col = PixelDataBase.COLS{mod(ind-1, 9)+1};

if ~exist('ix1', 'var')
    mess = sprintf([str{1} 'pixel %d (col=%s)'], offset + spacing*pix, col);
else % Need to find original index
    mess = sprintf([str{1} 'pixels %d and %d respectively (col=%s)'], offset + spacing*ix1(pix), ...
        offset + spacing*ix2(pix), col);
end

end
