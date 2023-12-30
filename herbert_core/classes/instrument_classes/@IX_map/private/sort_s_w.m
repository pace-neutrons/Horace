function [wkno_out, ns_out, s_out, w_out, unique_spec, unique_map] = ...
    sort_s_w (wkno, ns, s)
% Sort spectrum number and workspace number arrays
% Sort workspace numbers by increasing value, and for a given workspace sort
% the spectra by increasing spectrum number. Duplicate spectrum-to-workspace
% number pairs are removed.
%
%   >> [wkno_out, ns_out, s_out, w_out, unique_spec, unique_map] = ...
%                                                       sort_s_w (wkno, ns, s)
%
% Input:
% ------
%   wkno        Array of the corresponding workspaces
%   ns          Array of number of spectra in each workspace
%               (Assumed to have same number of elements as wkno and that
%               sum(ns) == numel(s))
%   s           Array of spectrum numbers
%
% Output:
% -------
%   wkno_out    Unique workspace numbers. Row vector.
%
%   ns_out      Number of spectra in each workspace. Row vector.
%
%   s_out       Spectrum numbers sorted by workspace number, and within each
%               workspace number by spectrum number. Row vector.
%
%   w_out       Workspace numbers for each of the spectra. Row vector (same
%               length as s_out)
%
%   unique_spec True if a spectrum is mapped to only one workspace.
%               False otherwise.
%
%   unique_map  True if there were no repeated spectrum-to-workspace number
%               entries in the input.
%               False otherwise


% Deal with all non-empty workspaces
w = replicate_iarray(wkno(:), ns(:));    % workspace for each spectrum
tmp = unique ([w(:), s(:)], 'rows');
s_out = tmp(:,2)';    % row vector
w_out = tmp(:,1)';    % row vector

% Determine if there were repeated entries in the mapping
if numel(s_out)==numel(s)
    unique_map = true;
else
    unique_map = false;
end

% Determine if a spectrum number appears more than once
if numel(s_out)==numel(unique(s_out))
    unique_spec = true;
else
    unique_spec = false;
end

% Get unique workspace numbers and number of spectra in each workspace
% (use the fact that w is already sorted)
ix = logical(diff([Inf, w_out]));   % note: logical(Inf)==true
wkno_out = w_out(ix);
ns_out = diff([find(ix), numel(ix)+1]);

% Insert the workspaces with zero spectra
% wkno is already sorted, so we can append the empty workspace numbers and sort
% again, then use the index array for the rearrangement to reorder the array
% made by appending the correct number of zeros to ns
wkno_empty = unique(wkno(ns==0));   % unique values only must be kept
[wkno_out, ix] = sort([wkno_out, wkno_empty(:)']);
ns_out = [ns_out, zeros(1,numel(wkno_empty))];
ns_out = ns_out(ix);
