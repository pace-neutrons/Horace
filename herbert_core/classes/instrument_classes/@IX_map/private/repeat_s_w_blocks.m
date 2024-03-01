function [wkno_out, ns_out, s_out] = repeat_s_w_blocks (s_beg, s_end, ...
    ngroup, s_dcn, wkno_beg, wkno_dcn, nrepeat, delta_s, delta_w)
% Create spectra and workspace number arrays from input ranges and repeat blocks
%
%   >> [wkno_out, ns_out, s_out] = repeat_s_w_blocks (s_beg, s_end, ...
%               ngroup, s_dcn, wkno_beg, wkno_dcn, nrepeat, delta_s, delta_w)
%
% Input arguments can be scalars (one schema), or vectors (multiple schema). The
% output for multiple schema are accumulated.
%
% Input:
% ------
%   s_beg       Array of spectrum range start numbers
%   s_end       Array of spectrum range end numbers; same number of elements as
%              s_beg
%   ngroup      Number of succesive spectra that are grouped together into one
%              workspace (array, same size as s_beg)
%   s_dcn       Increment in s(i):s_dcn(i):s_end(i); takes value +1 or -1;
%              same number of elements as s_beg
%   wkno_beg    Starting workspace numbers (array same size as s_beg).
%               Elements can be NaN, indicating placeholders to be resolved as
%              placing the block of workspaces defined by the schema contiguous
%              with the previous block and at higher workspace number.
%   wkno_dcn    Increment in workspace number: +1 or -1; array same size as
%              s_beg
%   nrepeat     Number of times to repeat the block of spectra and workspace
%              numbers defined by the arguments above (array, same size as s_beg)
%   delta_s     Increment in spectrum numbers between each repetition of the block
%              (array, same size as s_beg)
%   delta_w     Increment in workspace numbers between each repetition
%              (array, same size as s_beg)
%               Elements can be NaN, indicating placeholders to be resolved as
%              placing the each repeat block of workspaces defined in the schema
%              contiguous with the previous block and at higher workspace number.
%
% Output:
% -------
%   wkno_out    Workspace numbers (Column vector).
%               There may be multiple occurences of the same workspace number in
%               wkno_out, depending on the values of the input parameters (for
%               example, if the repeats result in overlapping lists of workspaces)
%
%   ns_out      Number of spectra in each workspace in the array wkno_out. 
%               (column vector, same length as wkno_out)
%               If a workspace number is repeated in wkno_out this does not cause
%               any problems: it is treated as the spectra contributing to the
%               workspace as being split into two or more sections
%
%   s_out       Spectrum numbers that will be grouped into workspaces according
%               as wkno_out and ns_out (column vector)


% Number of schema (or equivalently spectrum-to-workspace descriptors)
Nschema = numel(s_beg);

% Number of spectra and workspaces in a single block from each schema
nstot = abs(s_end - s_beg) +  1;
nwkno = 1 + floor((nstot - 1)./ngroup);

% Get minimum spectrum number from the full set of repeat blocks for each
% schema, and throw an error if the minimum spectrum number is less than 1
% No placeholder values are permitted for spectrum blocks, which simplifies the
% call to the function resolve_repeat_blocks.
for i = 1:Nschema
    [~, ~, s_min] = resolve_repeat_blocks ...
        (s_beg(i), s_dcn(i), delta_s(i), nstot(i), nrepeat(i));
    if s_min < 1
        error ('HERBERT:IX_map:invalid_argument', ['Spectrum array constructed for ',...
            'at least one block descriptor includes zero or negative spectrum numbers'])
    end
end

% Resolve place-holder values of wkno and delta_w. The value of wkno_max is
% updated from the previous iteration, so this for...end loop cannot be replaced
% by a call to arrayfun.
% Throw error if minimum workspace number is less than 1.
wkno_max = 0;
for i = 1:Nschema
    [wkno_beg(i), delta_w(i), wkno_min, wkno_max] = resolve_repeat_blocks ...
        (wkno_beg(i), wkno_dcn(i), delta_w(i), nwkno(i), nrepeat(i), wkno_max);
    if wkno_min < 1
        error ('HERBERT:IX_map:invalid_argument', ['Workspace array constructed for ',...
            'at least one block descriptor includes zero or negative workspace numbers'])
    end
end

% Create arrays of the spectrum and workspace numbers for each block, repeated
% as required by a schema, and accumulated across schemas
nwkno_schema = nwkno .* nrepeat;    % total number of workspaces in each schema
iwhi = cumsum(nwkno_schema);
iwlo = iwhi - nwkno_schema + 1;

nstot_schema = nstot .* nrepeat;    % total number of spectra in each schema
ishi = cumsum(nstot_schema);
islo = ishi - nstot_schema + 1;

wkno_out = NaN(iwhi(end), 1);
ns_out = NaN(iwhi(end), 1);
s_out = NaN(ishi(end), 1);
for i = 1:Nschema
    [wkno, ns] = wkno_create (nstot(i), ngroup(i), wkno_beg(i), wkno_dcn(i));
    s = s_beg(i):s_dcn(i):s_end(i);
    [wkno_out(iwlo(i):iwhi(i)), ns_out(iwlo(i):iwhi(i)), s_out(islo(i):ishi(i))] = ...
        repeat_s_w_arrays (wkno, ns, s, nrepeat(i), delta_s(i), delta_w(i));
end

end


%-------------------------------------------------------------------------------
function [wkno, ns] = wkno_create (nstot, ngroup, wkno_beg, wkno_dcn)
% Create array of workspace numbers for grouped spectra
%
%   >> wkno = wkno_create (ns, ngroup, wkno_beg, wkno_dcn)
%
% Input:
% ------
%   nstot       Number of spectra (>= 0)
%   ngroup      Spectrum-to-workspace grouping
%   wkno_beg       Initial workspace number
%   wkno_dcn    Increment direction: +1 or -1
%
% [Note: if wkno_dcn == -1 then wkno_beg is not the smallest workspace number, as the
%  workspace numbers in this case *decrease* from the starting value of wkno_beg.]
%
% Output:
% -------
%   wkno    Unique workspace numbers (Column vector)
%   ns      Number of spectra in each workspace (Column vector)
%
% EXAMPLE
%  Suppose we have spectra to be grouped in fours, with wkno starting at 10 and
% decreasing: we expect:
%                                       wkno            ns
%   wkno_create (14, 4, 10, -1)        [10;9;8;7]      [4;4;4;2]
%   wkno_create (13, 4, 10, -1)        [10;9;8;7]      [4;4;4;1]
%   wkno_create (12, 4, 10, -1)        [10;9;8]        [4;4;4]
%   wkno_create (11, 4, 10, -1)        [10;9;8]        [4;4;3]
%       :
%   wkno_create (1, 4, 10, -1)         [10]            [1]
%   wkno_create (0, 4, 10, -1)         [10]            [0]


% ns below correctly works for nstot=0, as ones(1,-1) == [] and so the first
% term in the expression for ns is [].
ns = [ngroup*ones(1,floor((nstot-1)/ngroup)), 1+rem((nstot-1),ngroup)];
wkno = wkno_beg + wkno_dcn * (0:numel(ns)-1);

end
