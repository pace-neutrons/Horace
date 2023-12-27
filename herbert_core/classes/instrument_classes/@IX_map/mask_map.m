function obj_out = mask_map (obj, mask)
% Creates IX_map object by removing spectra from the input IX_map
%
%   >> masked_map=mask_map(map,mask)
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
%   obj_out     Output IX_map object with the spectra in the mask removed


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
[spec, ix] = sort(IX_map.s);
ixlo = lower_index (spec);
ixhi = lower_index (spec);





obj_out=map;
keep=~ismember(map.s,mask.msk);
nw=numel(map.ns);
ns_out=zeros(1,nw);
ok=mat2cell(keep,1,map.ns);
for i=1:nw
    ns_out(i)=sum(ok{i});
end
obj_out.ns=ns_out;
obj_out.s=obj_out.s(keep);
