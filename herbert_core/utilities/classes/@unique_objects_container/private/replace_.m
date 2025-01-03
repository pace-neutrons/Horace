function self = replace_(self,obj,nuix)
%REPLACE replaces the object at non-unique index nuix in the container
% Input:
% - obj : the object to be added. This may duplicate an object
%         in the container, but it will be noted as a
%         duplicate; it is positioned at index nuix
% - nuix : position at which obj will be inserted. nuix must
%          be in the range 1:numel(self.idx_)
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

% check if you're trying to replace an object with an identical
% one. If so silently return.
[obj,objhash] = build_hash(obj);
curhash = self.stored_hashes_{self.idx_(nuix)};
if isequal(objhash, curhash)
    return;
end

% reduce the number of duplicates of the item to be replaced by
% 1.
oldix = self.idx_(nuix);
self.n_duplicates_(oldix) = self.n_duplicates_(oldix)-1;
% all existing objects with the hash specified were removed.
no_more_duplicates = self.n_duplicates_(oldix) == 0;

% Find if the object is already in the container. ix is
% returned as the index to the object in the container.
% hash is returned as the hash of the object. If ix is empty
% then the object is not in the container.
[ix,hash,obj] = self.find_in_container(obj);

% If the object is not in the container.
% store the hash in the stored hashes
% store the object in the stored objects
% take the index of the last stored object as the object index
if isempty(ix) % means obj not in container and should be added
    if no_more_duplicates
        self.unique_objects_{oldix} = obj;
        self.stored_hashes_{oldix} = hash;
        self.n_duplicates_(oldix) = self.n_duplicates_(oldix)+1;
    else
        self.unique_objects_ = [self.unique_objects_(:);{obj}]';

        self.stored_hashes_ = [self.stored_hashes_(:);hash]';
        self.idx_(nuix) = numel(self.unique_objects_);
        self.n_duplicates_ = [self.n_duplicates_(:)', 1];
    end
    % if it is in the container, then ix is the unique object index
    % in unique_objects_ and is put into idx_ as the unique index
    % for the new object
else
    if no_more_duplicates
        % need to remove the old object by replacing it with
        % the previous last object in unique_objects_


        % collect the final unique object currently in the
        % container
        lastobj = self.unique_objects_{end};
        lasthash = self.stored_hashes_{end};
        lastidx = numel(self.unique_objects_);

        if oldix<lastidx
            % oldix is the location where there are no more
            % duplicates, put the last object here
            self.unique_objects_{oldix} = lastobj;
            self.stored_hashes_{oldix} = lasthash;
            self.n_duplicates_(oldix) = self.n_duplicates_(lastidx);

            % reference all non-unique objects equivalent to the
            % last unique object as now referring to this oldix
            % location
            self.idx_(self.idx_==lastidx) = oldix;
        end

        % if the existing item was the last in stored, then
        % make it the new location
        if ix==lastidx
            ix=oldix;
        end

        % reduce the size of the unique object arrays
        self.unique_objects_(end)=[];
        self.stored_hashes_(end) = [];
        self.n_duplicates_(end) = [];

        % do the replacement
        self.idx_(nuix) = ix;
        self.n_duplicates_(ix) = self.n_duplicates_(ix)+1;

    else
        self.idx_(nuix) = ix;
        self.n_duplicates_(ix) = self.n_duplicates_(ix)+1;
    end
end
end % replace()
