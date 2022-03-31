function obj=make_sqw_data_from_proj_(obj,proj_in)
% Set data filed for sqw object from input of the form
%
%   >> [data,mess] = make_sqw_data_from_proj(proj)
%
% Input:
% ------
%
%   proj            Projection structure or object.
%
% Output:
% -------
%   data            Data structure of a valid data field in a dnd-type sqw object



% Original author: T.G.Perring
%


% Check projection
if ~(isa(proj_in,'aProjection') || isstruct(proj_in))
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'projection must be valid projection structure or projaxes object')
else
    if isstruct(proj_in)
        check = @(x)isfield(proj_in,x);
    else % aProjection
        check = @(x)isprop(proj_in,x);
    end
end
if ~isstruct(proj_in) && ~isa(proj_in,'ortho_proj')
    warning('HORACE:data_sqw_dnd:invalid_argument',...
        ['old data_sqw_dnd object fully supports ortho_proj only.'...
        ' Other projection types will be partially lost'])
end

flds = ortho_proj.data_sqw_dnd_export_list;
for i=1:numel(flds)
    if check(flds{i})
        obj.(flds{i}) = proj_in.(flds{i});
    end
end

data_fields  = {'s','e','npix'};
data_defined = false(3,1);
if isstruct(proj_in)
    for i=1:numel(data_fields)
        if isfield(proj_in,data_fields{i})
            obj.(data_fields{i}) = proj_in.(data_fields{i});
            data_defined(i) = true;
        end
    end
else
end
sz = obj.dims_as_ssize;
for i = 1:numel(data_fields)
    sz_exist = size(obj.(data_fields{i}));
    if ~(numel(sz_exist)== numel(sz) && any(sz_exist==sz)) && ~data_defined(i)
        obj.(data_fields{i}) = zeros(sz);
    end
end

