function [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin)
% Compare scalar sqw objects of same type
horace_info_level = get(hor_config, 'log_level');

% Check for presence of reorder and/or fraction option(s) (only relevant if sqw-type)
opt = struct('reorder', true, 'fraction', 1);
flagnames = {};
cntl.keys_at_end = false;
cntl.keys_once = false; % so name_a and name_b can be overridden
[args, opt, ~, ~, ok, mess] = parse_arguments(varargin, opt, flagnames, cntl);
if ~ok
    error(mess);
end
ism = cellfun(@(x)(ischar(x)||isstring(x))&&strcmp(x,'-ignore_date'),args);
if any(ism)
    ignore_date = true;
    args = args(~ism);
else
    ignore_date = false;
end
if ~islognumscalar(opt.reorder)
    error('SQW:equal_to_tol_internal', ...
        '''reorder'' must be a logical scalar (or 0 or 1)')
end
if ~isnumeric(opt.fraction) || opt.fraction < 0 || opt.fraction > 1
    error('SQW:equal_to_tol_internal', ...
        '''fraction'' must lie in the range 0 to 1 inclusive')
end

% Test equality of sqw class fields, excluding the raw pixels which is performed
% below. Pass class fields to the generic equal_to_tol.
class_fields = properties(w1);
% keep only the fields, which are compared in the main loop. Pixels will be
% compared separately.
keep = ~ismember(class_fields,'pix');
class_fields = class_fields(keep);
for idx = 1:numel(class_fields)
    field_name = class_fields{idx};
    tmp1 = w1.(field_name);
    tmp2 = w2.(field_name);
    if strcmp(field_name, 'data') && isa(tmp1.pix, 'PixelData')
        % pixel data equality is checked below
        tmp1.pix = PixelData();
        tmp2.pix = PixelData();
    end
    if strcmp(field_name,'main_header') && isa(tmp1,'main_header_cl') && ignore_date
        tmp1.creation_date = tmp2.creation_date;
        tmp1.creation_date_defined_privately= tmp2.creation_date_defined_privately;

    end
    name1 = [name_a,'.',field_name];
    name2 = [name_b,'.',field_name];

    [ok, mess] = equal_to_tol(tmp1, tmp2, args{:}, 'name_a', name1, 'name_b', name2);

    if ~ok
        return; % break on first failure
    end
end

% Perform pixel comparisons
if (~opt.reorder && opt.fraction == 1) || isempty(w1.data.pix) || isempty(w2.data.pix)
    % Test strict equality of all pixels including cases where one PixelData is empty
    [ok, mess] = equal_to_tol(w1.data.pix, w2.data.pix, args{:}, 'name_a', name_a, 'name_b', name_b);
else
    % Test pixels in a fraction of non-empty bins, accounting for reordering of pixels
    % if required

    % Check a subset of the bins with reordering
    npix = w1.data.npix(:);
    nend = cumsum(npix); % we already know that w1.data.npix and w2.data.npix are equal
    nbeg = nend - npix + 1;

    if opt.fraction > 0 && any(npix ~= 0)
        % Testing of bins requested and there is least one bin with more than one pixel
        % Get indices of bins to test
        ibin = find(npix > 0);
        num_non_empty = numel(ibin);
        if opt.fraction < 1
            ind = round(1:(1 / opt.fraction):numel(ibin))'; % Test only a fraction of the non-empty bins
            ibin = ibin(ind);
        end
        if horace_info_level >= 1
            disp(['                       Number of bins = ', num2str(numel(npix))])
            disp(['             Number of non-empty bins = ', num2str(num_non_empty)])
            disp(['Number of bins that will be reordered = ', num2str(numel(ibin))])
            disp(' ')
        end
        % Get the pixel indicies
        ipix = replicate_iarray(nbeg(ibin), npix(ibin)) + sawtooth_iarray(npix(ibin)) - 1;
        ibinarr = replicate_iarray(ibin, npix(ibin)); % bin index for each retained pixel
        % Now test contents for equality
        pix1 = w1.pix;
        pix2 = w2.pix;
        name_a = [name_a, '.pix'];
        name_b = [name_b, '.pix'];
        if opt.reorder
            % Sort retained pixels by bin and then run,det,energy bin indicies
            sort_by = {'run_idx', 'detector_idx', 'energy_idx'};
            [~, ix] = sortrows([ibinarr, pix1.get_data(sort_by, ipix)']);
            s1 = pix1.get_pixels(ipix);
            s1 = s1.get_pixels(ix);

            [~, ix] = sortrows([ibinarr, pix2.get_data(sort_by, ipix)']);
            s2 = pix2.get_pixels(ipix);
            s2 = s2.get_pixels(ix);

            % Now compare retained pixels
            [ok, mess] = equal_to_tol(s1, s2, args{:}, 'name_a', name_a, 'name_b', name_b);
        else
            s1 = pix1.get_pixels(ipix);
            s2 = pix2.get_pixels(ipix);
            [ok, mess] = equal_to_tol(s1, s2, args{:}, 'name_a', name_a, 'name_b', name_b);
        end
    end
end
