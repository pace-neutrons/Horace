function obj_out = section(obj, wkno_keep_in)
% Create a new IX_map by selecting particular workspaces
%
%   >> obj_out = section(obj, wkno_keep)
%
% Input:
% ------
%   obj         IX_map object
%   wkno_keep   List of workspace numbers from the IX_map object to retain ails))
%
% Output:
% -------
%   obj_out     IX_map obtained by retaining only the requested workspace numbers


% Get unique workspace numbers to keep
if ~isnumeric(wkno_keep_in) || any(wkno_keep_in(:)~=round(wkno_keep_in(:))) || ...
        any(wkno_keep_in(:)<=0) || ~all(isfinite(wkno_keep_in(:)))
    error ('HERBERT:IX_map:invalid_argument',...
        'All workspace numbers to keep must be integers greater than zero')
end
wkno_keep = unique(wkno_keep_in(:));

% Find location of workpsace numbers to keep in the input map
[isvalid_wkno, loc_in_wkno] = ismember(wkno_keep, obj.wkno);
if any(~isvalid_wkno)
    ind = find(~isvalid_wkno, 1);
    error ('HERBERT:IX_map:invalid_argument', ['Workspace number %d and possibly ',...
        'others to be kept are not one of the input workspace numbers'], wkno_keep(ind))
end

% Get the number of spectra in each of the workspaces to keep
ns = obj.ns;
ns_keep = ns(loc_in_wkno);  % number of spectra in each of the workspaces to keep

% Get a list of the spectra to keep
nscum = cumsum(ns);
is = ( replicate_iarray(nscum(loc_in_wkno) - ns(loc_in_wkno), ns_keep) + ...
    sawtooth_iarray(ns_keep) )';    % make the output a row vector
s_keep = obj.s(is);

% Create output IX_map
obj_out = IX_map (s_keep, 'wkno', wkno_keep, 'ns', ns_keep);
