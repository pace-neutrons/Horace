function [self,lidx] = add_if_new_single_(self,obj)
%ADD_IF_NEW_SINGLE_ Add single object to the unique objects container
% if it is not already there. If it is, increase number of object references
%
%
% Input
% -----
% self - the unique_objects_container in question
% obj  - the object to be added to the container
%
% Output
% ------
% self - the modified container (modified by adding obj)
% nuix - the insertion index at which obj is added in the container

% check that obj is of the appropriate base class
if ~isempty(self.baseclass_) && ~isa(obj, self.baseclass_)
    error('HERBERT:unique_objects_container:invalid_argument', ...
        'Adding object of class: "%s" to reference container of class "%s" is not allowed', ...
        class(obj),self.baseclass_);
end

% if ix and hash are not specified, call find_in_container to get them

[lidx,hash,obj] = self.find_in_container(obj);

% If the object is not in the container add it to the container.
if isempty(lidx) % means obj not in container and should be added

    [self,lidx] = self.check_and_expand_memory_if_necessary();

    p_free = self.lidx_(lidx);

    self.stored_hashes_{p_free}  = hash;
    self.unique_objects_{p_free} = obj;
    self.n_duplicates_(p_free)   = 1;
    self.idx_(p_free)            = p_free;
    self.n_unique_               = self.n_unique_+1;

else
    self.n_duplicates_(lidx) = self.n_duplicates_(lidx)+1;
end

