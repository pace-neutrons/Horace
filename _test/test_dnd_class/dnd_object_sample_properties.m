function [sample_properties,dependent_properties,const_prop ]=dnd_object_sample_properties(box_size)
% Function returns current set of sample properties, which may be set on
% dnd object and dependent properties, available on dnd object as read-only
% properties
% Outputs:
% sample_properties -- the map, containing pairs key -- property name -- value
%                      acceptable value to set to the property
% dependent_properties-the cellarray of read-only properties
sample_properties  = containers.Map({'filename','filepath','title','alatt'},...
    {'aaa','bbb','title',[1,2,3]});
sample_properties('angdeg') = [90,89,90];
sample_properties('offset')=[1,0,0,0];
sample_properties('img_offset') = [0,1,0,0];
sample_properties('label') = {'aaa','bbbb','cccc','e'};
if isempty(box_size)
    val =0;
else
    val  = ones(box_size);
end
bs = [box_size,ones(1,4-numel(box_size))];
sample_properties('s') = val;
sample_properties('e') = val;
sample_properties('npix') = val;
sample_properties('axes') = ortho_axes('nbins_all_dims',bs);
sample_properties('proj') = ortho_proj('alatt',4,'angdeg',90);

sample_properties('dax') = 1:numel(box_size);

dependent_properties = {'iint','iax','p','pax','img_range','nbins'};
const_prop = {'border_size','creation_date'}; % creation date is not constant but we do not care here
