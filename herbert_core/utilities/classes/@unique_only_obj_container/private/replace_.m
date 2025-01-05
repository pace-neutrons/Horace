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
curhash = self.stored_hashes_{self.idx_(gidx)};
if isequal(objhash, curhash)
    return;
end

% reduce the number of duplicates of the item to be replaced by
% 1.
old_lidx = self.idx_(gidx);
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
        p_free = self.lidx_(lidx_first_empty);
        
        self.unique_objects_{p_free} = obj;
        self.stored_hashes_{p_free}  = hash;
        self.idx_(p_free)            = p_free;
        self.n_duplicates_(p_free)   = 1;
        gidx                         = p_free;

        self.n_unique_               = self.n_unique_+1;
    end
    % if it is in the container, then ix is the unique object index
    % in unique_objects_ and is put into idx_ as the unique index
    % for the new object
else
    if no_more_duplicates
        % need to remove the old object by replacing it with
        % the previous last object in unique_objects_

        last_idx = self.n_unique_;
        % collect the final unique object currently in the
        % container
        lastobj = self.unique_objects_{last_idx};
        lasthash = self.stored_hashes_{last_idx};

        if old_lidx < last_idx
            % oldix is the location where there are no more
            % duplicates, put the last object here
            self.unique_objects_{old_lidx} = lastobj;
            self.stored_hashes_{old_lidx}  = lasthash;
            self.n_duplicates_(old_lidx)   = self.n_duplicates_(last_idx);

            % reference all non-unique objects equivalent to the
            % last unique object as now referring to this oldix
            % location
            self.idx_(self.idx_==last_idx) = old_lidx;
        end

        % if the existing item was the last in stored, then
        % make it the new location
        if lidx==lastidx
            lidx=old_lidx;
        end

        % reduce the size of the unique object arrays
        self.unique_objects_(end)=[];
        self.stored_hashes_(end) = [];
        self.n_duplicates_(end) = [];

        % do the replacement
        self.idx_(gidx) = lidx;
        self.n_duplicates_(lidx) = self.n_duplicates_(lidx)+1;

    else
        self.idx_(gidx) = lidx;
        self.n_duplicates_(lidx) = self.n_duplicates_(lidx)+1;
    end
end
end % replace()
