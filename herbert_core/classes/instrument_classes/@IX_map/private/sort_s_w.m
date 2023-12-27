function [wkno, ns, s, w, unique_spec, unique_map] = sort_s_w (is, iw)
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
%   wkno        Unique workspace numbers. Row vector.
%
%   ns          Number of spectra in each workspace. Row vector.
%
%   s           Spectrum numbers sorted by workspace number, and within each
%               workspace number by spectrum number. Row vector.
%
%   w           Workspace numbers for each of the spectra. Row vector (same
%               length as s)
%
%   unique_spec True if a spectrum is mapped to only one workspace;
%               false otherwise
%
%   unique_map  True if there were no repeated is-to-iw entries in the input;
%               false otherwise


% Catch trivial case of empty or scalar spectrum and workspace arrays
if numel(is) == 0
    wkno = zeros(1,0);
    ns = zeros(1,0);
    s = is(:)';   % turns empty into zeros(1,0), leaves scalar unchanged
    w = iw(:)';
    unique_spec = true;
    unique_map = true;
    return
end

% One or more spectra
tmp = unique ([iw(:), is(:)], 'rows');
s = tmp(:,2)';    % row vector
w = tmp(:,1)';    % row vector

% Determine if there were repeated entries in the mapping
if numel(s)~=numel(is)
    unique_map = true;
else
    unique_map = false;
end

% Determine if a spectrum number appears more than once
if numel(s)==numel(unique(s))
    unique_spec = true;
else
    unique_spec = false;
end

% Get unique workspace numbers and number of spectra in each workspace
% (use the fact that w is already sorted)
ix = logical(diff([Inf, w]));   % note: logical(Inf)==true
wkno = w(ix);
ns = diff([find(ix), numel(ix)+1]);
