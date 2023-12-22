function [is_out, iw_out] = repeat_s_w_arrays (is, iw, nrepeat, delta_isp, delta_iw)
% Create an array of spectrum and of workspace numbers by repeating reference
% arrays of each with succesive offsets, reulting in:
%
%   is_out = [is_out; is_out + delta_isp; is_out + 2*delta_isp,...
%                                                   , is_out + nrepeat*delta_isp]
%   iw_out = [iw_out; iw_out + delta_iw;  iw_out + 2*delta_iw,...
%                                                   , iw_out + nrepeat*delta_iw]
% The outputs are column vectors.
%
%   >> [is_out, iw_out] = repeat_s_w_arrays (is, iw, nrepeat, delta_isp, delta_iw)
%
% Input:
% ------
%   is          Input spectrum numbers array
%   iw          Input workspace numbers array. Must have the same number of
%              elements as input argument is
%   nrepeat     Number of times to repeat (nrepeat >= 1)
%   delta_isp   Offset between repeated blocks of spectra
%   delta_iw    Offset between repeated blocks of workspaces
%
% Output:
% -------
%   is_out      Output spectrum numbers (column vector)
%   iw_out      Output workspace numbers (column vector)


ns = numel(is);

% Catch the trivial case of no repetitions
if nrepeat==1
    is_out = is(:); % ensure output is a column vector
    iw_out = iw(:); % column vector
    return
end

% Determine if the minimum spectrum number in the repeated arrays is less than 1
% No placeholder values for spectra are permitted, which simplified the call to
% the function resolve_repeat_blocks
is_min_in = min(is(:));
is_max_in = max(is(:));
isp_dcn = 1;
ns_tmp = is_max_in - is_min_in + 1;     % created solely for this test
[~, ~, is_min] = resolve_repeat_blocks (is_min_in, isp_dcn, ...
    delta_isp, ns_tmp, nrepeat);
if is_min < 1
    error ('HERBERT:IX_map:invalid_argument', ['Spectrum array constructed for ',...
        'at least one repeated array includes zero or negative spectrum numbers'])
end


% Resolve a placeholder value for delta_iw, if present, and determine if the
% minimum workspace number in the repeated arrays is less than 1
iw_min_in = min(iw(:));
iw_max_in = max(iw(:));
iw_dcn = 1;
nw_tmp = iw_max_in - iw_min_in + 1;     % created solely for this test
iw_max_prev = 0;    % no previous mapping
[~, delta_iw, iw_min] = resolve_repeat_blocks (iw_min_in, iw_dcn, ...
    delta_iw, nw_tmp, nrepeat, iw_max_prev);
if iw_min < 1
    error ('HERBERT:IX_map:invalid_argument', ['Workspace array constructed for ',...
        'at least one repeated array includes zero or negative workspace numbers'])
end

% Create full list of spectrum and workspace numbers
is_out = NaN(ns*nrepeat, 1);
iw_out = NaN(ns*nrepeat, 1);

is_out(1:ns) = is;
iw_out(1:ns) = iw;
for irep=2:nrepeat
    ibeg = (irep-1)*ns + 1;
    iend = irep*ns;
    is_out(ibeg:iend) = is + (irep-1)*delta_isp;
    iw_out(ibeg:iend) = iw + (irep-1)*delta_iw;
end

end
