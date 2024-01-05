function [wkno_out, ns_out, s_out] = repeat_s_w_arrays (wkno, ns, s, nrepeat,...
    delta_s, delta_wkno)
% Create an array of spectrum and of workspace numbers by repeating reference
% arrays of each with succesive offsets, reulting in:
%
%   s_out = [s_out; s_out + delta_s; s_out + 2*delta_s;... s_out + nrepeat*delta_s]
%   wkno_out = [wkno_out; wkno_out + delta_wkno; wkno_out + 2*delta_wkno,...
%                                                  , wkno_out + nrepeat*delta_wkno]
% The outputs are column vectors.
%
%   >> [wkno_out, ns_out, s_out] = repeat_s_w_arrays (wkno, ns, s, ...
%                                                   nrepeat, delta_s, delta_wkno)
%
% Input:
% ------
%   wkno        Unique workspace numbers array
%   ns          Number of spectra in each workspace. Must have the same number
%               of elements as wkno
%   s           Spectrum numbers array
%   nrepeat     Number of times to repeat (nrepeat >= 1)
%   delta_s     Offset between repeated blocks of spectra
%   delta_wkno     Offset between repeated blocks of workspaces
%
% Output:
% -------
%   wkno_out    Workspace numbers (Column vector).
%               There may be multiple occurences of the same workspace number in
%               wkno_out, depending on the values of the input parameters (for
%               example, there is no requirement that the list of workspace
%               numbers in wkno contains just unique values)
%
%   ns_out      Number of spectra in each workspace in the array wkno_out. 
%               (column vector, same length as wkno_out)
%               If a workspace number is repeated in wkno_out this does not cause
%               any problems: it is treated as the spectra contributing to the
%               workspace as being split into two or more sections
%
%   s_out       Spectrum numbers that will be grouped into workspaces according
%               as wkno_out and ns_out (column vector)


% Catch the trivial case of no repetitions
if nrepeat==1
    wkno_out = wkno(:); % ensure output is a column vector
    ns_out = ns(:);
    s_out = s(:);
    return
end

% Determine if the minimum spectrum number in the repeated arrays is less than 1
% No placeholder values for spectra are permitted, which simplifies the call to
% the function resolve_repeat_blocks
s_min_in = min(s(:));
s_max_in = max(s(:));
s_dcn = 1;
ns_tmp = s_max_in - s_min_in + 1;     % created solely for this test
[~, ~, s_min] = resolve_repeat_blocks (s_min_in, s_dcn, ...
    delta_s, ns_tmp, nrepeat);
if s_min < 1
    error ('HERBERT:IX_map:invalid_argument', ['Spectrum array constructed for ',...
        'at least one repeated array includes zero or negative spectrum numbers'])
end


% Resolve a placeholder value for delta_wkno, if present, and determine if the
% minimum workspace number in the repeated arrays is less than 1
wkno_min_in = min(wkno(:));
wkno_max_in = max(wkno(:));
wkno_dcn = 1;
nwkno_tmp = wkno_max_in - wkno_min_in + 1;     % created solely for this test
wkno_max_prev = 0;    % no previous mapping
[~, delta_wkno, wkno_min] = resolve_repeat_blocks (wkno_min_in, wkno_dcn, ...
    delta_wkno, nwkno_tmp, nrepeat, wkno_max_prev);
if wkno_min < 1
    error ('HERBERT:IX_map:invalid_argument', ['Workspace array constructed for ',...
        'at least one repeated array includes zero or negative workspace numbers'])
end

% Create full list of spectrum and workspace numbers
nwkno = numel(wkno);
nstot = numel(s);
wkno_out = NaN(nwkno*nrepeat, 1);
s_out = NaN(nstot*nrepeat, 1);

wkno_out(1:nwkno) = wkno;
s_out(1:nstot) = s;
for irep=2:nrepeat
    iwbeg = (irep-1)*nwkno + 1;
    iwend = irep*nwkno;
    wkno_out(iwbeg:iwend) = wkno + (irep-1)*delta_wkno;
    isbeg = (irep-1)*nstot + 1;
    isend = irep*nstot;
    s_out(isbeg:isend) = s + (irep-1)*delta_s;
end
ns_out = repmat(ns(:), [nrepeat, 1]);

end
