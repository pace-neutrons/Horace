function [is_out, iw_out] = repeat_s_w_arrays (is, iw, nrepeat, delta_sp, delta_w)
% Create an array of spectrum and of workspace numbers by repeating reference
% arrays of each with succesive offsets, reulting in:
%
%   is_out = [is_out; is_out + delta_sp; is_out + 2*delta_sp,...
%                                                   , is_out + nrepeat*delta_sp]
%   iw_out = [iw_out; iw_out + delta_w;  iw_out + 2*delta_w,...
%                                                   , iw_out + nrepeat*delta_w]
% The outputs are column vectors.
%
%   >> [is_out, iw_out] = repeat_s_w_arrays (is, iw, nrepeat, delta_sp, delta_w)
%
% Input:
% ------
%   is          Input spectrum numbers array
%   iw          Input workspace numbers array. Must have the same number of
%              elements as input argument is
%   nrepeat     Number of times to repeat (nrepeat >= 1)
%   delta_sp    Offset between repeated blocks of spectra
%   delta_w     Offset between repeated blocks of workspaces
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

% Resolve a placeholder value for delta_w, if present, and determine if minimum
% workspace number is less than 1.
iw_min_in = min(iw(:));
iw_max_in = max(iw(:));
iw_dcn = 1;
nw = iw_max_in - iw_min_in + 1;
iw_max_prev = 0;    % no previous mapping
[~, delta_w, iw_min] = resolve_repeat_w_blocks (iw_min_in, iw_dcn, ...
    delta_w, nw, nrepeat, iw_max_prev);
if iw_min < 1
    error ('IX_map:invalid_argument', ['Workspace array constructed for ',...
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
    is_out(ibeg:iend) = is + (irep-1)*delta_sp;
    iw_out(ibeg:iend) = iw + (irep-1)*delta_w;
end

end
