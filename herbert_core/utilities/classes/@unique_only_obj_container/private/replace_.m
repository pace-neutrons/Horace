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
%
% it may be a duplicate but it is still the n'th object you
% added to the container. The number of additions to the
% container is implicit in the size of idx_.

% check that obj is of the appropriate base class

if ~isempty(self.baseclass_) && ~isa(obj, self.baseclass_)
    error('HERBERT:unique_objects_container:invalid_argument', ...
        'Can not place object of class "%s" in the container with baseclass: "%s"', ...
        class(obj),self.baseclass_);
end
self.check_if_range_allowed(gidx,varargin{:})

% check if you're trying to replace an object with an identical
% one. If so silently return.
[obj,objhash] = build_hash(obj);
curhash = self.stored_hashes_{self.lidx_(gidx)};
if isequal(objhash, curhash)
    return;
end

% reduce the number of duplicates of the item to be replaced by
% 1.
old_lidx = self.lidx_(gidx);
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
        self.n_duplicates_(old_lidx)  = self.n_duplicates_(old_lidx)+1;
    else
        [self,lidx_first_empty] = self.check_and_expand_memory_if_necessary();
        idx_free = self.lidx_(lidx_first_empty);

        self.unique_objects_{lidx_first_empty} = obj;
        self.stored_hashes_{lidx_first_empty}  = hash;
        self.idx_(idx_free)                    = lidx_first_empty;
        self.n_duplicates_(lidx_first_empty)   = 1;
        gidx                                   = lidx_first_empty;

        self.n_unique_           = self.n_unique_+1;
        self.max_obj_idx_        = max(self.n_unique_,self.max_obj_idx_);            
    end
    % if it is in the container, then ix is the unique object index
    % in unique_objects_ and is put into idx_ as the unique index
    % for the new object
else
    if no_more_duplicates
        % need to remove the old object by replacing it with
        % the previous last object in unique_objects_
        % old objet position defined by old_lidx

        last_idx       = self.n_unique_;
        self.n_unique_ = self.n_unique_-1; % move free pointer one step back

        % collect the final unique object currently in the
        % container
        lastobj  = self.unique_objects_{last_idx};
        lasthash = self.stored_hashes_{last_idx};
        lastdubl = self.n_duplicates_(last_idx);
        % set free index pointer to the position of the freed global index
        % this object do not exsit globally any more
        self.lidx_(last_idx) = old_lidx;
        self.idx_(old_lidx)  = 0;
        self.idx_(last_idx)  = old_lidx;        
        % move 
        self.unique_objects_{old_lidx} = lastobj;
        self.stored_hashes_{old_lidx}  = lasthash;
        self.n_duplicates_(old_lidx)   = lastdubl;
    else
        self.n_duplicates_(lidx) = self.n_duplicates_(lidx)+1;
        gidx = lidx;
    end
end
end % replace()
