function [ok, mess] = equal_to_tol_internal_(w1, w2, name_a, name_b, varargin)
% Compare scalar DnD objects of same type

% Check for presence of reorder and/or fraction option(s) (only relevant if sqw-type)
opt = struct('reorder', true, 'fraction', 1);
flagnames = {};
cntl.keys_at_end = false;
cntl.keys_once = false; % so name_a and name_b can be overridden
[args, opt, ~, ~, ok, mess] = parse_arguments(varargin, opt, flagnames, cntl);
if ~ok
    error(mess);
end
if ~islognumscalar(opt.reorder)
    error('HORACE:DnDBase:equal_to_tol_internal', ...
        '''reorder'' must be a logical scalar (or 0 or 1)')
end
if ~isnumeric(opt.fraction) || opt.fraction < 0 || opt.fraction > 1
    error('HORACE:DnDBase:equal_to_tol_internal', ...
        '''fraction'' must lie in the range 0 to 1 inclusive')
end

% Test equality of DnD class fields. Pass class fields to the generic equal_to_tol.
if isa(w1,'serializable')
    class_fields = w1.saveableFields();
else
    class_fields = properties(w1);
end
for idx = 1:numel(class_fields)
    field_name = class_fields{idx};
    tmp1 = w1.(field_name);
    tmp2 = w2.(field_name);
    name_aa = [name_a,'.',field_name];
    name_bb = [name_b,'.',field_name];    
    [ok, mess] = equal_to_tol(tmp1, tmp2, args{:}, 'name_a', name_aa, 'name_b', name_bb);

    if ~ok
        return; % break on first failure
    end
end
