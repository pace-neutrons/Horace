function struct1=combine_structures(struct1,struct2)
% function combines two input structures into one

sf =  fieldnames(struct2);
for i=1:numel(sf)
    struct1.(sf{i})=struct2.(sf{i});
end