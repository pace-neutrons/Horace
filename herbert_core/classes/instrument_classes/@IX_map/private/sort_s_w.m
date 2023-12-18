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
%   is          Array of spectrum numbers
%   iw          Array of the corresponding workspaces (assumed to have the same
%               number of elements as the input spectrum numbers array, is)
%
% Output:
% -------
%   is_sort     Spectrum numbers sorted by workspace number, and within each
%               workspace number by spectrum number. Row vector.
%
%   iw_sort     Workspace numbers for each of the spectra. Row vector (same
%               length as is_sort)
%
%   ns          Number of spectra in each workspace. Row vector.
%
%   wkno        Unique workspace numbers. Row vector.
%
%   unique_map  True if there were no repeated is-to-iw entries in the input;
%               false otherwise
%
%   unique_spec True if a spectrum is mapped to only one workspace;
%               false otherwise


% Catch trivial case of empty or scalar spectrum and workspace arrays
if numel(is) < 1
    is_sort = is(:)';   % turns empty into zeros(1,0), leaves scalar unchanged
    iw_sort = iw(:)';
    unique_map = true;
    unique_spec = true;
    return
end

% Two or more spectra
tmp = unique ([iw(:), is(:)], 'rows');
is_sort = tmp(:,2)';    % row vector
iw_sort = tmp(:,1)';    % row vector

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
ix = logical(diff([Inf, iw_sort]));   % note: logical(Inf)==true
wkno = iw_sort(ix);
ns = diff([find(ix), numel(ix)+1]);
