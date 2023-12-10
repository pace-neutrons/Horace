function [irun, idet, ien] = parse_pixel_indices (win, ipix)
% Return the run, detector and energy indices of pixels in one or more sqw objects
%
%   >> [irun, idet, ien] = parse_pixel_indices (win)        % for all pixels
%   >> [irun, idet, ien] = parse_pixel_indices (win, ipix)  % selected pixels
%
% Note: an efficient way of checking that ipix is consistent with all the sqw
% objects is to call without output arguments i.e.
%
%   >> parse_pixel_indices (win, ipix)
%
% This will return silently without spending time computing the output
% argument irun if the arguments are consistent, but will throw an error with an
% appropriate message
%
%
% Input:
% ------
% Checking validity:
%   win         Array of sqw objects
%
% [Optional]
%   ipix        Pixel indices for which the output is to be extracted from the
%               sqw object(s)
%
%               - Array of pixel indices. If there are multiple sqw objects,
%                 it is then applied to every sqw object
%
%               - Cell array of pixel indices arrays
%                   - only one array: applied to every sqw object, or
%                   - several pixel indices arrays: one per sqw object
%
% Output:
% -------
%   irun        Single sqw object: Array of indices into the experiment_info
%               Multiple sqw objects: Cell array of arrays, one per sqw object
%                                  Cell array has the same size as win
%
%   idet        Single sqw object: Array of detector indices for the pixels
%               Multiple sqw objects: Cell array of arrays, one per sqw object
%                                  Cell array has the same size as win
%
%   ien         Single sqw object: Energy bin indices for each pixel (column vector)
%               Multiple sqw objects: Cell array of arrays, one per sqw object
%                                  Cell array has the same size as win
%
% For each of irun, idet and ien, note that:
% - If ipix was not given, the output arrays for each sqw object are column vectors
% - If ipix was given, the output arrays for each sqw object have the same shape
%   as the corresponding array indices array within ipix


% Check number of sqw objects
nw = numel(win);
if nw == 0
    error('HORACE:parse_pixel_indices:invalid_argument', ...
        'Function was called with an empty sqw argument')
end
sz_win = size(win);

% If ipix is given, check that it is consistent with the number and sizes of the
% input sqw object(s)
ipix_present = exist('ipix', 'var');
if ipix_present
    % Get min and max indices in ipix (as column vectors)
    % If ipix is numeric, then get make it a cell array that is replicated to the
    % size of the input sqw object array. This is to make the block of code that
    % gets the output for a single sqw object much cleaner (without lots of
    % capturing of cases of numeric or cell array input, and scalar or array
    % cell arrays). The creation of a cell that is then input to repmat has no
    % memory or CPU penalty as the contents are not altered at any point, so it
    % is essentially just making a bunch of pointers.
    if iscell(ipix)
        % Assume cell array of integer arrays - none of them are permitted to be empty
        n_ipix = numel(ipix);
        if n_ipix==0 || any(cellfun(@isempty, ipix))
            error('HORACE:parse_pixel_indices:invalid_argument', ['The cell array ',...
                '''ipix'' is empty, or one or more arrays in ''ipix'' is empty'])
        end
        if ~any(numel(ipix) == [1,nw])
            error('HORACE:parse_pixel_indices:invalid_argument', ['The number of ',...
                'arrays in ''ipix'' must be 1 or the number of sqw objects: %d'], nw)
        end
        if numel(ipix)==1
            min_ipix = min(ipix{1}(:)) * ones(sz_win);
            max_ipix = max(ipix{1}(:)) * ones(sz_win);
            ipix_cellarray = repmat(ipix, sz_win);          % effectively a set of pointers
        else
            min_ipix = cellfun(@(x)(min(x(:))), ipix(:));   % output is column vector
            max_ipix = cellfun(@(x)(max(x(:))), ipix(:));
            ipix_cellarray = reshape(ipix, sz_win);
        end
    else
        % Assume ipix is an integer array - but it cannot be empty
        if isempty(ipix)
            error('HORACE:parse_pixel_indices:invalid_argument', ...
                'Optional pixel index argument ''ipix'' is empty')
        end
        if nw == 1
            min_ipix = min(ipix(:));
            max_ipix = max(ipix(:));
            ipix_cellarray = {ipix};
        else
            min_ipix = min(ipix(:)) * ones(size(win));
            max_ipix = max(ipix(:)) * ones(size(win));
            ipix_cellarray = repmat({ipix}, sz_win);    % make a cell for convenience later on
        end
    end
    
    % Get number of pixels in each sqw object
    npix = arrayfun(@(x)(x.npixels), win);
    
    % Check consistency
    bad = (min_ipix(:) < 1) | (max_ipix(:) > npix(:));
    if any(bad)
        ind = find(bad, 1);     % index of first bad dataset
        error('HORACE:parse_pixel_indices:invalid_argument', ['One or more pixel ',...
            'indices are out of the valid range 1-%d for dataset %d'], npix(ind), ind)
    end
end

% If no return arguments, simply have a silent return.
% This goes against the default Matlab behaviour for functions, which is to
% return the first output argument in a variable called 'ans'. However, that
% could be fairly CPUtime expensive here.
if nargout == 0
    return
end

% Get the return arguments
% We have repackaged ipix so that it is a cell array with size equal to the size
% of win. In the following we only have to branch on (1) the presence or absence
% of ipix, (2) win being an object array or a cell array of sqw objects
if ipix_present
    if nw == 1
        % Outputs will be numeric arrays
        [irun, idet, ien] = parse_pixel_indices_private (win, ipix_cellarray);
    else
        % Outputs are cell arrays of numeric arrays
        % Note that the call to arrayfun will work because internally the
        % function parse_pixel_indixes_private spots if ipix is a cell array
        % with one element and extracts the contents
        [irun, idet, ien] = arrayfun(@parse_pixel_indices_private, win, ...
            ipix_cellarray, 'uniformOutput', false);
    end
else
    if nw == 1
        % Outputs will be numeric arrays
        [irun, idet, ien] = parse_pixel_indices_private (win);
    else
        % Outputs are cell arrays of numeric arrays
        [irun, idet, ien] = arrayfun(@parse_pixel_indices_private, win, ...
            'uniformOutput', false);
    end
end

end

%-------------------------------------------------------------------------------
function [irun, idet, ien] = parse_pixel_indices_private (win, ipix)
% Get the experiment indices (sometimes known as 'header index'), detector
% indices and energy bin indices for an sqw object.
% Private function that assumes all validity checks for the input arguments have
% already been done.
%
% Input:
% ------
%   win         sqw object
%   ipix        Pixel indices array, or cell array with one element that is an
%               array of pixel indices
%
% Output:
% -------
%   irun -|
%   idet  |-    Indices corresponding to the selected pixels (column vectors)
%   ien  -|

pix = win.pix;
experiment = win.experiment_info;

if pix.num_pixels > 0
    % At least one pixel, so need to do some work
    if exist('ipix', 'var')
        % Get irun, idet, ien for pixels indicated by ipix with same shape as ipix
        if iscell(ipix)
            ipix = ipix{1};     % get the indices array inside ipix
        end
        run_idx = reshape(pix.run_idx(ipix), size(ipix));
        irun = experiment.get_experiment_idx(run_idx);
        idet = reshape(pix.detector_idx(ipix), size(ipix));
        ien = reshape(pix.energy_idx(ipix), size(ipix));
    else
        % Get irun, idet, ien for all pixels in the sqw object
        run_idx = pix.run_idx(:);   % make column
        irun = experiment.get_experiment_idx(run_idx); % irun same shape as run_idx i.e. column
        idet = pix.detector_idx(:); % make column
        ien = pix.energy_idx(:);    % make column
    end
else
    % Catch the case of no pixels for simplicity
    irun = zeros(0,1);  % convention is column vector
    idet = zeros(0,1);
    ien = zeros(0,1);
end

end
