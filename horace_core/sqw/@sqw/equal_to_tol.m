function [ok, mess] = equal_to_tol(w1, w2,varargin)
%
%
[ok,mess,is_recursive,opt,defined] = process_inputs_for_eq_to_tol(w1, w2, ...
    inputname(1), inputname(2),true, varargin{:});
if ~ok
    return;
end
if ~is_recursive && ~defined.nan_equal
    opt.nan_equal = true;
end
if ~is_recursive && ~defined.reorder
    opt.reorder = true;
end

% Test equality of sqw class fields, excluding the raw pixels which is performed
% below. Pass class fields to the generic equal_to_tol.
class_fields = properties(w1);
% keep only the fields, which are compared in the main loop. Pixels will be
% compared separately, and is_filebacked option does not count as
% filebacked and memory backed objects should be equal
keep = ~ismember(class_fields,{'pix','is_filebacked'});
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
    if opt.ignore_date
        if strcmp(field_name,'main_header') && isa(tmp1,'main_header_cl')
            tmp1.creation_date = tmp2.creation_date;
            tmp1.creation_date_defined_privately= tmp2.creation_date_defined_privately;
        end
        if strcmp(field_name,'data') && isa(tmp1,'DnDBase')
            tmp1.creation_date = tmp2.creation_date;
            tmp2.creation_date = tmp1.creation_date;
        end
    end
    lopt = opt;
    lopt.name_a = [opt.name_a,'.',field_name];
    lopt.name_b = [opt.name_b,'.',field_name];

    [ok, mess] = equal_to_tol(tmp1, tmp2, opt);
    if ~ok
        return; % break on first failure
    end
end

% Compare pix
if opt.reorder
    opt.npix = w1.data.npix(:);
end
opt.name_a = [opt.name_a,'.pix'];
opt.name_b = [opt.name_b,'.pix'];
[ok, mess] = equal_to_tol(w1.pix, w2.pix,opt);
end
