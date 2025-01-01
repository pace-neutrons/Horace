function [self,uidx] = add_if_new_single_(self,obj)
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
    warning('HERBERT:unique_objects_container:invalid_argument', ...
        'not correct base class; object was not added');
    uidx = [];
    return;
end

% if ix and hash are not specified, call find_in_container to get them

[uidx,hash,obj] = self.find_in_container(obj);

% If the object is not in the container.
% store the hash in the stored hashes
% store the object in the stored objects
% take the index of the last stored object as the object index
if isempty(uidx) % means obj not in container and should be added
    self.stored_hashes_ = [self.stored_hashes_(:);hash]';
    self.unique_objects_ = [self.unique_objects_(:); {obj}]';

    uidx = numel(self.unique_objects_);
    self.n_duplicates_ = [self.n_duplicates_(:); 1]';
    self.idx_ = [self.idx_(:)', uidx]; % alternative syntax: cat(2,self.idx_,uidx);
else
    self.n_duplicates_(uidx) = self.n_duplicates_(uidx)+1;
end

