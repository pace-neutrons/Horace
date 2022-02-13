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
end
if ~isstruct(proj_in) && ~isa(proj_in,'ortho_proj')
    warning('HORACE:data_sqw_dnd:invalid_argument',...
        'old data_sqw_dnd object fully supports ortho_proj only. Other projection types will be partially lost')
end

prs = ortho_proj();
flds = prs.data_sqw_dnd_export_list;
for i=1:numel(flds)
    if isfield(proj_in,flds{i})
        obj.(flds{i}) = proj_in.(flds{i});
    end
end


if isstruct(proj_in)
    other_fields = {'s','e','npix','img_db_range'};
    for i=1:numel(other_fields)
        if isfield(proj_in,other_fields{i})
            obj.(other_fields{i}) = proj_in.(other_fields{i});            
        end
    end
else
    obj.img_db_range = obj.get_binning_range();    
end


