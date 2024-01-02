function obj_out = mask (obj, mask)
% Creates IX_map object by removing spectra from the input IX_map
%
%   >> obj_out = mask (obj, mask)
%
% Input:
% ------
%   obj         IX_map object
%
%   mask        Numeric list of spectra to be removed from the IX_map object, or
%               an IX_mask object (which will contain such an array)
%
% Output:
% -------
%   obj_out     Output IX_map object with the spectra in the mask removed.
%               Note: it will contain workspaces which were originally empty or
%               are now empty following the removal of amsked spectra.


% Catch trivial case of no mask
if nargin==1
    obj_out = obj;  % No mask array
    return
end

% Check mask
if ~isa(mask, 'IX_mask')
    mask = IX_mask(mask);
end

% Remove masked spectra
% ---------------------
% Create an IX_map which has only those workspaces with at least one of the
% unmasked spectra
w = obj.w;
s = obj.s;
keep = ~ismember(s, mask.msk);
map = IX_map(s(keep), 'wkno', w(keep));

% Make a list of those workspaces that
% - are in the input map and contain no spectra 
% - have at least one spectrum in the input map but are now fully masked
wkno_empty = obj.wkno(~ismember(obj.wkno, map.wkno));

% Output map will have the workspaces that were originally empty, or are now
% empty following the removal of spectra that are masked
wkno = [map.wkno, wkno_empty];
ns = [map.ns, zeros(1,numel(wkno_empty))];
s = map.s;

obj_out = IX_map(s, 'wkno', wkno, 'ns', ns);
