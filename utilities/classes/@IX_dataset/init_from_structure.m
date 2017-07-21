function obj = init_from_structure(obj,in)
% init object or array of objects from a structure with appropriate
% fields. The fields must have public get and set methods

if numel(in) > 1
    out = repmat(IX_dataset_1d,numel(in),1);
    in1d = reshape(in,numel(in),1);
    for i = 1:numel(in)
        out(i) = out(i).init_from_structure(in1d(i));
    end
    obj = reshape(out,size(in));
    return
end
fld_names = fieldnames(in);

for i=1:numel(fld_names)
    fld = fld_names{i};
    obj.(fld) = in.(fld);
end
[obj,mess] = obj.isvalid();
if ~isempty(mess)
    error('IX_dataset:invalid_argument',mess);
end
