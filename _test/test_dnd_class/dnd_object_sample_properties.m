function [sample_properties,dependent_properties]=dnd_object_sample_properties(box_size)
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
%sample_properties('u_to_rlu')=eye(3);     | TODO?
%sample_properties('ulen') = [1,2,3,1];    |
sample_properties('label') = {'aaa','bbbb','cccc','e'};
if isempty(box_size)
    val =0;
else
    val  = ones(box_size);
end
sample_properties('s') = val;
sample_properties('e') = val;
sample_properties('npix') = val;
sample_properties('axes') = axes_block(sum(box_size>1));
sample_properties('proj') = ortho_proj();

sample_properties('dax') = 1:numel(box_size);

dependent_properties = {'iint','iax','p','pax','img_range','nbins'};
