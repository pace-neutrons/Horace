function obj = init_from_structure(obj,in)
% init object or array of objects from a structure with appropriate
% fields

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
accepted_flds = obj.public_fields_list_;
memb = ismember(fld_names,accepted_flds);
if ~all(memb)
    err_fields = fld_names(~memb);
    err_fields = cellfun(@(fld)([fld,'; ']),err_fields,'UniformOutput',false);
    err_str = [err_fields{:}];
    error('IX_dataset_1d:invalid_argument',...
        'Input structure fields: %s can not be used to set IX_dataset_1d',err_str);
end
for i=1:numel(fld_names)
    fld = fld_names{i};
    obj.(fld) = in.(fld);
end
