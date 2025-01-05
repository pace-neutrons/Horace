function self = check_combo_arg_(self,with_checks)
% runs after changing property or number of properties to check
% the consistency of the changes against all other relevant
% properties
%
% Inputs:
% with_checks  -- if true, each following hash is compared with
%                 the previous hashes and if coincedence found,
%                 throw the error. Necessary when replacing the
%                 unique_objects to check that new objects are
%                 indeed unique.

max_idx = max(self.idx_);
if max_idx ~= self.n_unique
    error('HERBERT:unique_objects_container:invalid_argument',...
        ['Container validiry have been violated. Object indexes point outside of the stored objects.\n' ...
        'Max index=%d, Number of stored unique objects: %d'],...
        max_idx,numel(self.unique_objects_));
end
uni_ind = unique(self.idx_);
if isempty(uni_ind)
    if ~isempty(self.unique_objects_)
        self.idx_ = 1:numel(self.unique_objects_);
    end
else
    if  (uni_ind(1) ~= 1 || numel(uni_ind) ~= self.n_unique)
        error('HERBERT:unique_objects_container:invalid_argument',...
            'Container has unique objects which are not referred by any indexes')
    end
end
if ~isempty(self.baseclass_)
    if isempty(self.unique_objects_)
        return;
    end
    if iscell(self.unique_objects_)
        is_class_type = cellfun(@(x)isa(x,self.baseclass_),self.unique_objects_);
    else
        is_class_type = arrayfun(@(x)isa(x,self.baseclass_),self.unique_objects_);
    end
    if ~any(is_class_type)
        non_type_ind = find(~is_class_type);
        invalid_obj = self.unique_objects_(non_type_ind(1));
        if iscell(invalid_obj)
            invalid_obj = invalid_obj{1};
        end
        error('HERBERT:unique_objects_container:invalid_argument',...
            'The type of the container is set to %s but the objects %s are of different type=%s',...
            self.baseclass,disp2str(non_type_ind),class(invalid_obj))
    end
end
%
if isempty(self.stored_hashes_) && ~isempty(self.unique_objects)
    self = self.rehashify_all(with_checks);
end
