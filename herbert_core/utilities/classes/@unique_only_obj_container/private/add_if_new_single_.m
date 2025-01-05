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

% call find_in_container to get poisition and hash of the object
[lidx,hash,obj] = self.find_in_container(obj);

% If the object is not in the container add it to the container.
if isempty(lidx) % means obj not in container and should be added

    [self,lidx] = self.check_and_expand_memory_if_necessary();

    idx_free = self.lidx_(lidx);

    self.stored_hashes_{lidx}  = hash;
    self.unique_objects_{lidx} = obj;
    self.n_duplicates_(lidx)   = 1;
    % set unique global index of objects in the container to refer to
    % current object location
    self.idx_(idx_free)        = lidx;
    self.n_unique_             = self.n_unique_+1;
    self.max_obj_idx_          = max(self.n_unique_,self.max_obj_idx_);
    %
    lidx     = idx_free;
else
    self.n_duplicates_(lidx) = self.n_duplicates_(lidx)+1;
end

