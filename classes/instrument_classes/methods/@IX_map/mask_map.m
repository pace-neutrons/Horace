function map_out=mask_map(map,mask)
% Creates map description by masking spectra in the input map
%
%   >> masked_map=mask_map(map,mask)
%
% Input:
% ------
%   map         Mapping of spectra to workspaces
%
%   mask        Mask: list of spectra to be removed from mapping file or
%              an IX_mask object (which will contain such an array)
%
% Output:
% -------
%   map_out     Output IX_map object with the spectra in the mask removed

% Original author: T.G.Perring
%
% Modified:
%   TGP     22 Nov 2009:    Resolve serious bug in algorithm that generates masked map


% Catch some trivial cases
if ~isa(map,'IX_map'), error('First argument must be a map object'), end
if nargin==1
    map_out=map;
    return
end
if nargin==2
    if ~isa(mask,'IX_mask')
        try
            mask=IX_mask(mask);
        catch
            error('Second argument must be IX_mask or an array of positive integers')
        end
    end
end

% Remove masked spectra
map_out=map;
keep=~ismember(map.s,mask.msk);
nw=numel(map.ns);
ns_out=zeros(1,nw);
ok=mat2cell(keep,1,map.ns);
for i=1:nw
    ns_out(i)=sum(ok{i});
end
map_out.ns=ns_out;
map_out.s=map_out.s(keep);
