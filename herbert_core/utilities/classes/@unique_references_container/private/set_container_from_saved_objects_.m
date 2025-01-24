function self = set_container_from_saved_objects_(self,val)
%SET_CONTAINER_FROM_SAVED_OBJECTS sets unique_references_container storage
% to values, specified by input. 
%
% Usually the imput is the unique_objects_container stored by saveobj, 
% but cellarray of objects is also accepted

if isa(val,'unique_objects_container')
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
    [storage,gidx] = storage.add(val);
    self.idx_ = gidx; % 

elseif iscell(val)
    if isempty(self.baseclass)
        error('HERBERT:unique_references_container:runtime_error', ...
            'Incomplete setup. Can not setup unique unnamed unique_references_container by cellarray of objects');

    end
    storage = unique_obj_store.instance().get_objects(self.baseclass);
    % all check should be performed in storage
    storage.unique_objects = val;

else
    error('HERBERT:unique_references_container:invalid_argument', ...
        'unique_objects must be a unique_objects_container');
end
unique_obj_store.instance().set_objects(storage);
