function  [bsm,key_map,missing] = calc_const_block_sizes(pos_info,cbl_maps,varargin)
% Calculate the byte-sizes and positions of constant blocks for upgrading data on hdd



bsm  = containers.Map();
key_map = containers.Map();
missing = containers.Map();


keys = cbl_maps.keys();
if nargin>2
    keys2check = varargin;
    if ~all(ismember(keys2check,keys))
        nonmem=~ismember(keys2check,keys);
    end
else
    keys2check = keys;
end

for i=1:numel(keys2check )
    theKey = keys2check{i};
    fld_range = cbl_maps(theKey);
    
    if nargout>1
        key_map(theKey) = fld_range;
    end
    
    s1 = get_value(pos_info,fld_range{1});
    s2 = get_value(pos_info,fld_range{2});
    
    bsm(theKey) =[s1; s2-s1];
end

function val = get_value(struc,key)
if iscell(key)
    subs = struc.(key{1});
    if isempty(subs)
        val = [];
    else
        val = get_value(subs,key{2:end});
    end
else
    val = struc.(key);
end

