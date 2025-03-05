function [self,gidx] = add_if_new_single_(self,obj)
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
% gidx - the insertion index at which obj is added in the container

% check that obj is of the appropriate base class
if ~isempty(self.baseclass_) && ~isa(obj, self.baseclass_)
    error('HERBERT:unique_objects_container:invalid_argument', ...
        'Adding object of class: "%s" to reference container of class "%s" is not allowed', ...
        class(obj),self.baseclass_);
end

% call find_in_container to get position and hash of the object
[lidx,hash,obj] = self.find_in_container(obj,false);

% If the object is not in the container add it to the container.
if isempty(lidx) % means obj not in container and should be added

    [self,lidx_new] = self.check_and_expand_memory_if_necessary();

    gidx_free = self.lidx_(lidx_new);

    self.stored_hashes_{gidx_free}  = hash;
    self.unique_objects_{gidx_free} = obj;
    self.n_duplicates_(gidx_free)   = 1;
    % set unique global index of objects in the container to refer to
    % current object location
    self.idx_(gidx_free)       = gidx_free;
    self.n_unique_             = self.n_unique_+1;
    self.max_obj_idx_          = max(self.max_obj_idx_,gidx_free);
    %
    gidx     = gidx_free;
else
    gidx     = self.lidx_(lidx);    
    self.n_duplicates_(gidx) = self.n_duplicates_(gidx)+1;
end

