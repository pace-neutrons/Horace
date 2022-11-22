function obj = check_combo_arg_(obj,do_rehashify,with_checks)
% runs after changing property or number of properties to check
% the consistency of the changes against all other relevant
% properties
%
% Inputs:
% do_rehashify -- if true, run rehashify procedure. 
%
% with_checks  -- if true, each following hash is compared with
%                 the previous hashes and if coincedence found,
%                 throw the error. Necessary when replacing the
%                 unique_objects to check that new objects are
%                 indeed unique.


max_idx = max(obj.idx_);
if max_idx ~= obj.n_unique
    error('HERBERT:unique_objects_container:invalid_argument',...
        'Object indexes point outside of the stored objects. Max index=%d, Number of stored unique objects: %d',...
        max_idx,numel(obj.unique_objects_));
end
uni_ind = unique(obj.idx_);
if ~isempty(uni_ind) && ...
        (uni_ind(1) ~= 1 || numel(uni_ind) ~= obj.n_unique)
    error('HERBERT:unique_objects_container:invalid_argument',...
        'Container has unique objects which are not referred by any indexes')
end
if ~isempty(obj.baseclass_)
    if isempty(obj.unique_objects_)
        return;
    end
    if iscell(obj.unique_objects_)
        is_class_type = cellfun(@(x)isa(x,obj.baseclass_),obj.unique_objects_);
    else
        is_class_type = arrayfun(@(x)isa(x,obj.baseclass_),obj.unique_objects_);
    end
    if ~any(is_class_type)
        non_type_ind = find(~is_class_type);
        invalid_obj = obj.unique_objects_(non_type_ind(1));
        if iscell(invalid_obj)
            invalid_obj = invalid_obj{1};
        end
        error('HERBERT:unique_objects_container:invalid_argument',...
            'The type of the container is set to %s but the objects %s are of different type=%s',...
            obj.baseclass,disp2str(non_type_ind),class(invalid_obj))
    end
end
if do_rehashify
    obj = obj.rehashify_all(with_checks);
end
