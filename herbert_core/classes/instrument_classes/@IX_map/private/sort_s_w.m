function [is_sort, iw_sort, ns, wkno, unique_map, unique_spec] = sort_s_w (is, iw)
% Sort spectrum and workspace number arrays
% Sort into increasing workspace number, and within a given workspace, into
% increasing spectrum number.
% Removes duplicate entries.
%
%   >>
%
% Input:
% ------
%   is          Column vector of spectrum numbers (non-empty)
%   iw          Column vector of the corresponding workspaces (same length as is)
%
% Output:
% -------
%   is_sort     Spectrum numbers sorted by workspace number, and within each
%               workspace number by spectrum number. Column vector.
%
%   iw_sort     Workspace numbers for each of the spectra. Column vector (same
%               length as is_sort)
%
%   ns          Number of spectra in each workspace. Column vector.
%
%   wkno        Unique workspace numbers. Column vector.
%
%   unique_map  True if there awere no repeated is-to-iw entries; else false
%
%   unique_spec True if a spectrum is mapped to only one workspace; else false


% Catch trivial case of only a single spectrum and workspace
if numel(is)==1
    is_sort = is;
    iw_sort = iw;
    unique_map = true;
    unique_spec = true;
    return
end
    
% Two or more spectra
tmp = unique ([iw, is]);
is_sort = tmp(:,2);
iw_sort = tmp(:,1);

% Determine if there were repeated entries in the mapping
if numel(is_sort)~=numel(is)
    unique_map = true;
else
    unique_map = false;
end

% Determine if a spectrum number appears more than once
if numel(is_sort)==numel(unique(is_sort))
    unique_spec = true;
else
    unique_spec = false;
end

% Get unique workspace numbers and number of spectra in each workspace
% (use the fact that iw_sort is already sorted)
ix = logical(diff([inf; iw_sort]));   % note: logical(inf)==true
wkno = iw_sort(ix);
ns = diff([find(ix); numel(ix)+1]);
