function bsm = init_map_(obj,pos_info)
% Calculate map containing the positions 
%   Detailed explanation goes here
bsm  = containers.Map();

keys2check = obj.block_names_;
for i=1:numel(keys2check )
    theKey = keys2check{i};
    fld_range = obj.const_block_map_(theKey);
    
    
    [ok,s1] = get_value(pos_info,fld_range{1});
    if ~ok
        continue % positin block not present at all
    end
    [ok,s2] = get_value(pos_info,fld_range{2});
    if ~ok
        error('SQW_FILE_IO:invalid_argument',...
            'field %s for block %s is not among input positions structure',fld_range{2},theKey);
    end
    if numel(s1) == 1
        sz = s2(1)-s1;
        if sz>0
            bsm(theKey) =[s1;sz];
        else
            bsm(theKey) =[];
        end
    else
        if strncmp(theKey,'$0',2)
                bsm(theKey) =[s1(end); s2(end)-s1(end)];
        elseif strncmp(theKey,'$n',2)
            res = zeros(2,numel(s1)-1);
            for j=1:numel(s1)-1
                res(:,j) = [s2(j); s1(j+1)-s2(j)];
            end
            bsm(theKey) =res;
        elseif isempty(s1) || isempty(s2)
            bsm(theKey) =[];
        else
            sz = s2(1)-s1(1);
            if sz>0
                bsm(theKey) =[s1;sz];
            else
                bsm(theKey) =[];
            end
        end
    end
end


function [ok,val] = get_value(struc,key)
%
val = [];
if iscell(key)
    if isfield(struc,key{1})
        ok = true;
    else
        ok = false;
        return
    end
    subs = struc.(key{1});
    if isempty(subs)
        val = [];
    else
        [ok,val] = get_value(subs,key{2:end});
    end
else
    if isfield(struc,key)
        ok = true;
    else
        ok = false;
        return
    end
    nel = numel(struc);
    if nel == 1
        val = struc.(key);
    else
        val = zeros(1,nel);
        for i=1:nel
            val(i) = struc(i).(key);
        end
    end
end



