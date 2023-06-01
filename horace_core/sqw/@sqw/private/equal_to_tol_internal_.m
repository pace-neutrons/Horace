function [ok, mess] = equal_to_tol_internal_(w1, w2, name_a, name_b, varargin)
% Compare scalar sqw objects of same type
horace_info_level = get(hor_config, 'log_level');

% Check for presence of reorder and/or fraction option(s) (only relevant if sqw-type)
opt = struct('reorder', true, 'fraction', 1);
flagnames = {};
cntl.keys_at_end = false;
cntl.keys_once = false; % so name_a and name_b can be overridden
[args, opt, ~, ~, ok, mess] = parse_arguments(varargin, opt, flagnames, cntl);
if ~ok
    error(mess);
end
ism = cellfun(@(x)(ischar(x)||isstring(x))&&strcmp(x,'-ignore_date'),args);
if any(ism)
    ignore_date = true;
    args = args(~ism);
else
    ignore_date = false;
end
if ~islognumscalar(opt.reorder)
    error('SQW:equal_to_tol_internal', ...
        '''reorder'' must be a logical scalar (or 0 or 1)')
end
if ~isnumeric(opt.fraction) || opt.fraction < 0 || opt.fraction > 1
    error('SQW:equal_to_tol_internal', ...
        '''fraction'' must lie in the range 0 to 1 inclusive')
end

% Test equality of sqw class fields, excluding the raw pixels which is performed
% below. Pass class fields to the generic equal_to_tol.
class_fields = properties(w1);
% keep only the fields, which are compared in the main loop. Pixels will be
% compared separately.
keep = ~ismember(class_fields,'pix');
class_fields = class_fields(keep);
for idx = 1:numel(class_fields)
    field_name = class_fields{idx};
    if strcmp(field_name,'pix') %pixels compared separately at the end
        continue;
    end
    if ismember(field_name,{'runid_map','creation_date'}) % runid maps will
        %  be compared as part of experiment and creation date  as part of
        % components comparison
        continue;
    end
    tmp1 = w1.(field_name);
    tmp2 = w2.(field_name);
    if ignore_date
        if strcmp(field_name,'main_header') && isa(tmp1,'main_header_cl')
            tmp1.creation_date = tmp2.creation_date;
            tmp1.creation_date_defined_privately= tmp2.creation_date_defined_privately;
        end
        if strcmp(field_name,'data') && isa(tmp1,'DnDBase')
            tmp1.creation_date = tmp2.creation_date;
            tmp2.creation_date = tmp1.creation_date;
        end
    end
    name1 = [name_a,'.',field_name];
    name2 = [name_b,'.',field_name];

    [ok, mess] = equal_to_tol(tmp1, tmp2, args{:}, 'name_a', name1, 'name_b', name2);
    if ~ok
        return; % break on first failure
    end
end

% Compare pix
[ok, mess] = equal_to_tol(w1.pix, w2.pix, args{:}, ...
                          'reorder', opt.reorder, 'npix', w1.data.npix(:), 'fraction', opt.fraction, ...
                          'name_a', [name_a, '.pix'], 'name_a', [name_b, '.pix']);
end
