function [is_out, iw_out] = repeat_s_w_blocks_multi (isp_beg, isp_end, ...
    ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w)
% Create spectra and workspace number arrays from input ranges and repeat counts
%
%   >> [is_out, iw_out] = repeat_s_w_blocks_multi (isp_beg, isp_end, ...
%                   ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w)
%
% Input:
% ------
%   isp_beg     Array of spectrum range start numbers
%   isp_end     Array of spectrum range end numbers; same number of elements as
%              isp_beg
%   ngroup      Number of succesive spectra that are grouped together into one
%              workspace (array, same size as isp_beg)
%   isp_dcn     Increment in isp(i):isp_dcn(i):isp_end(i); takes value +1 or -1;
%              same number of elements as isp_beg
%   iw_beg      Starting workspace numbers (array same size as isp_beg)
%   iw_dcn      Increment in workspace number: +1 or -1; array same size as
%              isp_beg
%   nrepeat     Number of times to repeat the block of spectra and workspace
%              numbers defined by the arguments above (array, same size as isp_beg)
%   delta_sp    Increment in spectrum numbers between each repetition of the block
%              (array, same size as isp_beg)
%   delta_w     Increment in workspace numbers between each repetition
%              (array, same size as isp_beg)
%
% Output:
% -------
%   is_out      Array of spectrum numbers defined by the above
%   iw_out      Array of workspace numbers defined by the above


% Number of workspaces in a single block from each repeat-block descriptor
nw = 1 + floor(abs(isp_end-isp_beg)./ngroup);

% Resolve place-holder values of iw and delta_w. The value of iw_max is updated
% from the previous iteration, so this cannot be replaced by arrayfun
ndescriptors = numel(isp_beg);
iw_max = 0;
for i = 1:ndescriptors
    [iw_beg(i), delta_w(i), iw_min, iw_max] = resolve_w_range (iw_beg(i), iw_dcn(i), ...
        delta_w(i), nw(i), nrepeat(i), iw_max);
    if iw_min < 1
        error ('IX_map:invalid_argument', ['Workspace array constructed for ',...
            'at least one block descriptor includes zero or negative workspace numbers'])
    end
end

% Compute the total number of spectra and workspaces
ns = abs(isp_end - isp_beg) +  1;   % could have isp_beg > isp_end
ns_descriptor = ns .* nrepeat;

ihi = cumsum(ns_descriptor);
ilo = ihi - ns_descriptor + 1;

is_out = NaN(ihi(end), 1);
iw_out = NaN(ihi(end), 1);
for i = 1:ndescriptors
    is = isp_beg(i):isp_dcn(i):isp_end(i);
    iw = iw_create (ns(i), ngroup(i), iw_beg(i), iw_dcn(i));
    [is_out(ilo(i):ihi(i)), iw_out(ilo(i):ihi(i))] = repeat_s_w_arrays (...
        is, iw, nrepeat(i), delta_sp(i), delta_w(i));
end

end


%-------------------------------------------------------------------------------
function iw = iw_create (ns, ngroup, iw_beg, iw_dcn)
% Create array of workspace numbers for grouped spectra
%
%   >> iw = iw_create (ns, ngroup, iw_beg, iw_dcn)
%
% Input:
% ------
%   ns      Number of spectra
%   ngroup  Grouping
%   iw_beg  First workspace number
%   iw_dcn  Increment direction: +1 or -1
%
% Output:
% -------
%   iw      Column vector with workspace numbers
%
% EXAMPLE
%  Suppose 14 spectra to be grouped in fours, with iw starting at 10 and
% decreasing: 
%   >> iw = iw_create (14, 4, 10, -1)
% then expect the output
%   [10 10 10 10 9 9 9 9 8 8 8 8 7 7]'


nrep = [ngroup*ones(1, floor(ns/ngroup)), rem(ns,ngroup)];
iw_unique = iw_beg + iw_dcn * (0:numel(nrep)-1);
iw = replicate_iarray (iw_unique, nrep);

end
