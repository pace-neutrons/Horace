function [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin)
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
    error('''reorder'' must be a logical scalar (or 0 or 1)')
end
if ~isnumeric(opt.fraction) || opt.fraction < 0 || opt.fraction > 1
    error('''fraction'' must lie in the range 0 to 1 inclusive')
end

% Test equality of DnD class fields. Pass class fields to the generic equal_to_tol.
class_fields = properties(w1);
for idx = 1:numel(class_fields)
    field_name = class_fields{idx};
    tmp1 = w1.(field_name);
    tmp2 = w2.(field_name);
    [ok, mess] = equal_to_tol(tmp1, tmp2, args{:}, 'name_a', name_a, 'name_b', name_b);
end

% Return if failed before expensive or unnecessary PixelData tests
if ~ok
    return
end
