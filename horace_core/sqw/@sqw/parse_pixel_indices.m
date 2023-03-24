function [irun, idet, ien] = parse_pixel_indices (win,indx,iw)
% Return the indices to pixels
%
% Check validity (sizes and extent of arrays, format of input arguments etc)
%   >> parse_pixel_indices (win,indx)
%
% Get indices for a particular sqw object
%   >> [irun,idet,ien] = parse_pixel_indices (win)           % all pixels
%   >> [irun,idet,ien] = parse_pixel_indices (win,indx)      % pixels in indx (if scalar)
%   >> [irun,idet,ien] = parse_pixel_indices (win,indx,iw)   % Index in indx if not scalar
%
% Input:
% ------
% Checking validity:
%   win         Array of sqw objects, or cell array of scalar sqw objects
%
%   indx        Pixel indices to be extracted fromt he sqw object(s)
%
%               Single sqw object:
%               ------------------
%                 - ipix            Column vector of pixels indices
%            *OR* - irun_idet_ien   Array of run, detector and energy bin index
%                                  (array size nx3 where n is the number of pixels)
%
%               Multiple sqw objects:
%               ---------------------
%                 - As above: assumed to apply to all sqw objects,
%            *OR* - Cell array of the above, one cell array per sqw object
%                  e.g. if two sqw objects:
%                       {ipix1, ipix2}
%                       {irun_idet_ien_1, irun_idet_ien_2}
%
% [Optional]
%   iw          Indices of the sqw objects in win into the indexing arrays
%              given by indx, one index for each for the sqw objects in win.
%               This can be used to fine tune the use of indx for a specific
%              sqw object or set of sqw objects without having to divide
%              up indx. If indx has only one entry, then it is assumed to
%              apply for any value of iw.
%
% Output:
% -------
%   irun        Single sqw object: Indexes of the experiments, containing
%
%               Run indices for each pixel (column vector)
%               Multiple sqw objects: Array of column vectors, one per object
%
%   idet        Single sqw object: Detector indices for each pixel (column vector)
%               Multiple sqw objects: Array of column vectors, one per object
%
%   ien         Single sqw object: Energy bin indices for each pixel (column vector)
%               Multiple sqw objects: Array of column vectors, one per object


nw = numel(win);

if nw == 0
    error('HORACE:parse_pixel_indices:invalid_argument', 'Function called with empty sqw argument')
end

nout = nargout;     % number of optional output arguments in series irun, idet, ien


% Case of only w as an input argument
% -----------------------------------
if nargin==1
    if nout>0
        irun = cell(size(win));
        idet = cell(size(win));
        ien  = cell(size(win));
        for i = 1:nw
            if iscell(win)
                pix = win{i}.pix;
            else
                pix = win(i).pix;
            end

            run_idx= pix.get_fields('run_idx', 'all')';
            if iscell(win)
                irun_tmp = arrayfun(@(x) win{i}.runid_map(x),run_idx);
            else
                irun_tmp = arrayfun(@(x) win(i).runid_map(x),run_idx);
            end
            irun{i} = irun_tmp;
            idet{i} = pix.get_fields('detector_idx', 'all')';
            ien{i}  = pix.get_fields('energy_idx', 'all')';
        end

        if nw == 1
            irun = irun{1};
            idet = idet{1};
            ien = ien{1};
        end

    end

    return
end

% Case when given index array(s)
% ------------------------------
% Check iw, if given, is positive and consistent with the number of sqw objects
if exist('iw','var')
    if numel(iw)~=numel(win)
        error('HORACE:parse_pixel_indices:invalid_argument', 'Number of indices in index argument ''iw'' must equal the number of sqw objects');
    elseif any(iw<1)
        error('HORACE:parse_pixel_indices:invalid_argument', 'Indices in index argument ''iw'' must be greater or equal to zero');
    end
end

% Check indx
if ~iscell(indx)
    indx = {indx};
end

nind = numel(indx);

if any(~cellfun(@(x) isnumeric(x) && (size(x, 2) == 1 || size(x, 2) == 3), indx))
    error('HORACE:parse_pixel_indices:invalid_argument', 'Each indexing array must be a numeric column vector or an nx3 array of run-detector-energy bin indices');
end

indx_internal = indx;        % standard name for internal working

if nind==1
    iw_internal = ones(nw,1);    % every sqw object has the same indx array - indx is effectively infinitely long
else
    if exist('iw','var')
        if any(iw) > nind
            error('HORACE:parse_pixel_indices:invalid_argument', 'Value(s) in the index argument ''iw'' must lie in the range 1 - %d', nind);
        end
        iw_internal = iw;
    else
        if nind ~= nw
            error('HORACE:parse_pixel_indices:invalid_argument', 'If there is more than one indexing array, the number must match the number of sqw objects');
        end
        iw_internal = 1:nw;  % one indx array per sqw object
    end
end

% Check consistency
for i=1:nw
    if iscell(win)
        wtmp = win{i};
    else
        wtmp = win(i);
    end

    indx_tmp = indx_internal{iw_internal(i)};

    if size(indx_tmp,2)==1
        if ~(max(indx_tmp)<=wtmp.pix.num_pixels && min(indx_tmp)>=0)
            error('HORACE:parse_pixel_indices:invalid_argument', 'One or more pixel indices outside range of sqw object');
        end
        continue
    end

    if iscell(wtmp.header)
        nrun = numel(wtmp.header);
        ne = cellfun(@(x)(numel(x.en)-1),wtmp.header);
    else
        nrun = 1;
        ne = numel(wtmp.header.en)-1;
    end
    ndet = numel(wtmp.detpar.x2);
    irun = indx_tmp(:,1);
    idet = indx_tmp(:,2);
    ien  = indx_tmp(:,3);

    if ~(max(irun)<=nrun && min(irun)>=0)
        error('HORACE:parse_pixel_indices:invalid_argument', 'One or more run indices outside range of sqw object');
    elseif ~(max(idet)<=ndet && min(idet)>=0)
        error('HORACE:parse_pixel_indices:invalid_argument', 'One or more detector indices outside range of sqw object');
    elseif ~(all(ien<=ne(irun)) && min(ien)>=0)
        error('HORACE:parse_pixel_indices:invalid_argument', 'One or more energy bin indices outside range of sqw object');
    end
end

% Fill output arrays if required
if nout>0
    irun = cell(size(win));
    idet = cell(size(win));
    ien  = cell(size(win));

    for i = 1:nw
        indx_tmp = indx_internal{iw_internal(i)};
        if size(indx_tmp,2)==1
            if iscell(win)
                pix = win{i}.pix;
                runid_map = win{i}.runid_map;
            else
                pix = win(i).pix;
                runid_map = win(i).runid_map;
            end

            run_idx= pix.get_fields('run_idx', indx_tmp)';
            irun{i} = arrayfun(@(x)runid_map(x),run_idx);
            idet{i} = pix.get_fields('detector_idx', indx_tmp)';
            ien{i}  = pix.get_fields('energy_idx', indx_tmp)';
        else
            irun{i} = indx_tmp(:,1);
            %? Does this index need to be transformed from run_idx to
            %index ?
            idet{i} = indx_tmp(:,2);
            ien{i}  = indx_tmp(:,3);
        end
    end

    if nw == 1
        irun = irun{1};
        idet = idet{1};
        ien = ien{1};
    end
end

end
