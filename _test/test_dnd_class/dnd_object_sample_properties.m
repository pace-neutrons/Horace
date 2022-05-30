function [sample_properties,dependent_properties]=dnd_object_sample_properties()
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
sample_properties('uoffset')=[1,0,0,0];
sample_properties('u_to_rlu')=eye(3);
sample_properties('ulen') = [1,2,3,1];
sample_properties('label') = {'aaa','bbbb','cccc','e'};
sample_properties('s') = ones(3,3);
sample_properties('e') = ones(3,3);
sample_properties('npix') = ones(3,3);
sample_properties('img_range') =[-1,-2,-3,-4;2,3,4,5];
sample_properties('nbins_all_dims') = [10,20,30,40];
sample_properties('dax') = [1,2,3,4];

dependent_properties = {'iint','iax','p','pax','isvalid'};
