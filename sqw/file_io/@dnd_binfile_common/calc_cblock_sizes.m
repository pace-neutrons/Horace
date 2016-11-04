function  [bsm,key_map] = calc_cblock_sizes(obj,varargin)
% Calculate the byte-sizes and positions of constant blocks for upgrading data on hdd


this_pos = obj.get_pos_info();
cbl_map = obj.const_blocks_map();
bsm  = containers.Map();
key_map = containers.Map();


keys = cbl_map.keys();
if nargin>1
    keys2check = varargin;
    if ~all(ismember(keys2check,keys))
        nonmem=~ismember(keys2check,keys);
        nonkey = join(keys2check(nonmem),'; ');
        error('SQW_FILE_IO:invalid_arguments',...
            'calc_cblock_sizes: invalid constant block names: %s to calculate size provided',...
            nonkey);
    end
else
    keys2check = keys;
end

for i=1:numel(keys2check )
    theKey = keys2check{i};
    fld_range = cbl_map(theKey);

    if nargout>1
        key_map(theKey) = fld_range;
    end
    
    s1 = get_value(this_pos,fld_range{1});
    s2 = get_value(this_pos,fld_range{2});
    
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

