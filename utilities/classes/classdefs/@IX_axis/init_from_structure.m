function obj = init_from_structure(axis,in)
% init object or array of objects from a structure with appropriate
% fields

if numel(in) > 1
    out = repmat(axis,numel(in),1);
    in1d = reshape(in,numel(in),1);
    for i = 1:numel(in)
        out(i) = out(i).init_from_structure(in1d(i));
    end
    obj = reshape(out,size(in));
    return
end
% simple setter, wothout fancy fields evaluation. If will fail on wrong
% fields anyway.
fld_names = fieldnames(in);
obj = axis;
for i=1:numel(fld_names)
    fld = fld_names{i};
    obj.(fld) = in.(fld);
end
