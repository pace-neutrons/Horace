function [self,storage] = set_container_from_saved_objects_(self,val)
%SET_CONTAINER_FROM_SAVED_OBJECTS sets unique_references_container storage
%  to values, specified in unique_object container. Presumably previusly
%  saved by saveobj

% unique_obj_container resets everything, so no point of
% throwing in this situation. Just reset target
if isempty(self.baseclass)
    self.baseclass  = val.baseclass;
end
if ~strcmp(self.baseclass,val.baseclass)
    if self.n_objects>0
        error('HERBERT:unique_references_container:invalid_argument', ...
            'Can not asign unique objects of type "%s" to non-empty container of type "%s"',...
            val.baseclass,self.baseclass);
    else
        self.baseclass_ = val.baseclass;
    end
end
storage = unique_obj_store.instance().get_objects(self.baseclass);
self.idx_ = zeros(1,val.n_objects);
for i=1:val.n_objects
    [storage,gidx] = storage.add(val(i));
    self.idx_(i) = gidx;
end
