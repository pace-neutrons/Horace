function [self,nuix] = add_single_(self,obj)
%ADD_SINGLE_ Add single object to the unique objects container


% Find if the object is already in the container. ix is
% returned as the index to the object in the container.
% hash is returned as the hash of the object. If ix is empty
% then the object is not in the container.
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
        'not correct base class; object was not added');
end

% call find_in_container to get ix and hash
[ix,hash,obj] = self.find_in_container(obj);


% If the object is not in the container.
% store the hash in the stored hashes
% store the object in the stored objects
% take the index of the last stored object as the object index
if isempty(ix) % means obj not in container and should be added
    self.stored_hashes_  = [self.stored_hashes_(:);hash]';
    self.unique_objects_ = [self.unique_objects_(:); {obj}]';

    ix = numel(self.unique_objects_);
end

% add index ix to the array of indices
% know the non-unique object index - the number of times you
% added an object to the container - say k. idx_(k) is the
% index of the unique object in the container.
self.idx_ = [self.idx_(:)', ix]; % alternative syntax: cat(2,self.idx_,ix);
nuix = numel(self.idx_);
