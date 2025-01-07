function [self,gidx] = replace_(self,obj,gidx,varargin)
%REPLACE replaces the object at global index gidx in the container
% Input:
% - obj : the object to be added. This may duplicate an object
%         in the container, but it will be noted as a
%         duplicate; it is positioned at index gidx
% - gidx : position at which obj will be inserted. maximal value of gidx
%          must not exceed maximal number of objects ever present in the
%          container.
% Output:
% - self : the changed container (as this is a value class)
% - gidx : permanent global index of the object to be referred by
%          reference container. E.g. the position of the pointer to object
%          location in self.idx_ array.


% check that obj is of the appropriate base class
if ~isempty(self.baseclass_) && ~isa(obj, self.baseclass_)
    error('HERBERT:unique_objects_container:invalid_argument', ...
        'Can not place object of class "%s" in the container with baseclass: "%s"', ...
        class(obj),self.baseclass_);
end
self.check_if_range_allowed(gidx,varargin{:})

old_lidx = self.idx_(gidx);
% check if you're trying to replace an object with an identical
% one. If so silently return.
[obj,objhash] = build_hash(obj);
curhash = self.stored_hashes_{old_lidx};
if isequal(objhash, curhash)
    return;
end

% reduce the number of duplicates of the item to be replaced by
% 1.
self.n_duplicates_(old_lidx) = self.n_duplicates_(old_lidx)-1;
% all existing objects with the hash specified were removed.
no_more_duplicates = self.n_duplicates_(old_lidx) == 0;

% Find if the object is already in the container. ix is
% returned as the index to the object in the container.
% hash is returned as the hash of the object. If ix is empty
% then the object is not in the container.
[lidx,hash,obj] = self.find_in_container(obj);

% If the object is not in the container.
% store the hash in the stored hashes
% store the object in the stored objects
% take the index of the last stored object as the object index
if isempty(lidx) % means obj not in container and should be added
    if no_more_duplicates
        self.unique_objects_{old_lidx} = obj;
        self.stored_hashes_{old_lidx} = hash;
        self.n_duplicates_(old_lidx)  = 1;
    else
        [self,lidx_first_empty] = self.check_and_expand_memory_if_necessary();
        idx_free = self.lidx_(lidx_first_empty);

        self.unique_objects_{idx_free} = obj;
        self.stored_hashes_{idx_free}  = hash;
        self.n_duplicates_(idx_free)   = 1;

        self.idx_(idx_free) = idx_free;
        gidx                = idx_free;

        self.n_unique_           = self.n_unique_+1;
        self.max_obj_idx_        = max(self.n_unique_,self.max_obj_idx_);
    end
    % if it is in the container, then ix is the unique object index
    % in unique_objects_ and is put into idx_ as the unique index
    % for the new object
else
    if no_more_duplicates % some old object has been replaced.
        % old object position defined by old_lidx.
        % number of used objects have decreased.

        last_idx       = self.n_unique_;
        self.n_unique_ = self.n_unique_-1; % move free pointer one step back

        % swap points to free memory and occupied memory
        self.lidx_(old_lidx) = last_idx;        
        self.lidx_(last_idx) = old_lidx;
        % clear empty idx to save memory and ensure no error occurs if
        % invalid 
        self.unique_objects_{old_lidx} = [];
        self.stored_hashes_{old_lidx}  = '';        
        self.idx_(old_lidx)            = 0;
        gidx= lidx;
    else
        gidx = self.lidx_(lidx);        
    end
    % increase number of duplicates at target
    self.n_duplicates_(lidx) = self.n_duplicates_(lidx)+1;
end
end % replace()
