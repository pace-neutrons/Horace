function struc = shallow_struct_(obj)
% Convert object into structure, considering only top level properties.
% All property values object remain untouched.
%
flds = indepFields(obj);

cell_dat = cell(numel(flds),numel(obj));
for j=1:numel(obj)
    for i=1:numel(flds)
        fldn = flds{i};
        val = obj(j).(fldn);
        cell_dat{i,j} = val;
    end
end
struc = cell2struct(cell_dat,flds,1);
if numel(obj)>1
    struc = reshape(struc,size(obj));
end
