function [iw_beg, delta_w, iw_min, iw_max] = resolve_repeat_w_blocks ...
    (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev)
% Resolve first workspace number and/or step size for repeated blocks, in the
% case when one or both are indicated as placeholders (i.e. NaN) that mean they
% are to be set such that the block of workspaces defined by the spectra-workspace
% mapping block is adjacent to the previous block (at higher workspace numbers)
%
%   >> [iw_beg, delta_w, iw_min, iw_max] = resolve_repeat_w_blocks ...
%                   (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev)
%
% Input:
% ------
%   iw_beg_in   Initial workspace number in the block definition - could be NaN
%               i.e. placeholder
%
%   iw_dcn      Increment between workspace numbers for a single block: +1 or -1
%
%   delta_w_in  Step size between repeated blocks. Meaningful only if nrepeat>1.
%               Could be NaN i.e. placeholder.
%
%   nw          Number of workspaces in a single block i.e. before nrepeat is
%               applied
%
%   iw_max_prev Maximum workspace number from the previous block definition
%
% Output:
% -------
%   iw_beg      Resolved value of initial workspace number
%
%   delta_w     Resolved value of step size between repeated blocks
%
%   iw_min      Minimum workspace number across the blocks (can be less than
%               iw_beg if iw_dcn == -1)
%
%   iw_max      Maximum workspace number across the repeated blocks


% Relative to iw i.e. for iw==0; will account for iw later.
if isnan(delta_w_in)
    delta_w = nw;
    if iw_dcn>0
        % First block: runs from iw:iw+nw-1, then next iw+nw:iw+2*nw etc
        iw_min = 0;
        iw_max = nrepeat * nw - 1;
    else
        % First block: runs from iw:-1:iw-nw+1, then next iw+nw:-1:iw+1, the next
        % iw+2*nw:-1:iw+nw-1 etc.
        iw_min = -nw + 1;
        iw_max = (nrepeat - 1) * nw;
    end
else
    delta_w = delta_w_in;
    % Min and max for first block - depends on iw_dcn:
    if iw_dcn>0
        iw_min = 0;
        iw_max = nw - 1;
    else
        iw_min = -nw + 1;
        iw_max = 0;
    end
    % Now account for repeats
    if nrepeat > 1
        if delta_w_in > 0
            iw_max = iw_max + (nrepeat - 1) * delta_w_in;
        elseif delta_w_in < 0
            iw_min = iw_min - (nrepeat - 1) * delta_w_in;
        end
    end
end

% Now account for iw_in, resolving if NaN
if isnan(iw_beg_in)
    % Minimum workspace number becomes iw_max_prev + 1
    iw_beg = iw_max_prev - iw_min + 1;
else
    iw_beg = iw_beg_in;
end
iw_min = iw_min + iw_beg;
iw_max = iw_max + iw_beg;
