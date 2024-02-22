function [ix_beg, delta_ix, ix_min, ix_max] = resolve_repeat_blocks ...
    (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat, ix_max_prev)
% Resolve the first spectrum or workspace number, and/or step size for repeated
% blocks, in the case when one or both are indicated as placeholders (i.e. NaN).
% Placeholder values mean that mean the actual values will be set such that the
% block of spectra or workspaces defined by the spectra-workspace mapping block
% is adjacent to the previous block (at higher spectrum or workspace numbers)
%
%   >> [ix_beg, delta_ix, ix_min, ix_max] = resolve_repeat_blocks ...
%                   (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat, ix_max_prev)
%
% In the following documentation the word 'item' should be read as 'spectrum'
% or 'workspace'
% 
% Input:
% ------
%   ix_beg_in   Initial item number in the block definition.
%               Could be NaN i.e. placeholder
%
%   ix_dcn      Increment between item numbers for a single block: +1 or -1
%
%   delta_ix_in Step size between repeated blocks. Meaningful only if nrepeat>1.
%               Could be NaN i.e. placeholder.
%
%   nx          Number of items in a single block i.e. before nrepeat is
%               applied ( >= 1)
%
%   nrepeat     Number of times the block is repeated ( >= 1; 1 means only one 
%               block so no additional repeats)
%
%   ix_max_prev Maximum item number from the previous block definition
%               Only needed if delta_ix_in is a placeholder.
%
% Output:
% -------
%   ix_beg      Resolved value of initial item number
%
%   delta_ix    Resolved value of step size between repeated blocks
%
%   ix_min      Minimum item number across the blocks (can be less than
%               ix_beg if ix_dcn == -1)
%
%   ix_max      Maximum item number across the repeated blocks


% Relative to ix_beg_in(1) i.e. treat ix_beg_in==0; will account for the true
% value later.
if isnan(delta_ix_in)
    delta_ix = nx;
    if ix_dcn>0
        % First block: runs from 0:ix+(nx-1), then next nx:ix+(2*nx-1) etc
        ix_min = 0;
        ix_max = nrepeat * nx - 1;
    else
        % First block: runs from 0:-1:-nx+1, then next -nx:-1:-2*nx+1, the next
        % -2*nx:-1:-3*nx+1 etc.
        ix_min = -nx + 1;
        ix_max = (nrepeat - 1) * nx;
    end
else
    delta_ix = delta_ix_in;
    % Min and max for first block - depends on ix_dcn:
    if ix_dcn>0
        ix_min = 0;
        ix_max = nx - 1;
    else
        ix_min = -nx + 1;
        ix_max = 0;
    end
    % Now account for repeats (only necessary if nrepeat > 1)
    if nrepeat > 1
        if delta_ix_in > 0      % ix_min is the value for first block
            ix_max = ix_max + (nrepeat - 1) * delta_ix_in;
        elseif delta_ix_in < 0  % ix_max is the value for first block
            ix_min = ix_min - (nrepeat - 1) * abs(delta_ix_in);
        end
    end
end

% Now account for ix_beg_in, resolving if NaN
if isnan(ix_beg_in)
    % Set the starting value so that the minimum item number for the set of 
    % repeated blocks becomes ix_max_prev + 1
    if ~exist('ix_max_prev','var')
        error ('HERBERT:IX_map:invalid_argument', ['Must provide ''ix_max_prev'' ',...
            'if block repeat increment is a placeholder value'])
    end
    ix_beg = ix_max_prev - ix_min + 1;
else
    % Starting value for the set of repeated block is defined as ix_beg_in
    ix_beg = ix_beg_in;
end
ix_min = ix_min + ix_beg;
ix_max = ix_max + ix_beg;

end
