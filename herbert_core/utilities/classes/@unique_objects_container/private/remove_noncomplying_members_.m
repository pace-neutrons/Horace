function self = remove_noncomplying_members_(self,new_class_name)
% Remove all elements, which are not the members of the class of type
% specified as input.

if isempty(self.unique_objects_)
    return;
end
is_compliant = cellfun(@(x)(isa(x,new_class_name)),self.unique_objects);

if all(is_compliant)
    return;
end

self.unique_objects_ = self.unique_objects_(is_compliant);
if isempty(self.unique_objects_)
    self.unique_objects_ = cell(1,0);
    self.stored_hashes_  = cell(1,0);
    self.idx_            = zeros(1,0);
    self.n_duplicates_   = zeros(1,0);
    return;
end
self.stored_hashes_  =  self.stored_hashes_(is_compliant);
%
nonc_ind = find(~is_compliant);
idx = self.idx_;
to_remove = false(1,numel(idx));
for i=1:numel(nonc_ind)
    to_remove = to_remove|idx == nonc_ind(i);
    to_reduce = idx>nonc_ind(i);
    %
    idx(to_reduce) = idx(to_reduce) - 1;    
    nonc_ind       = nonc_ind-1;
end
self.idx_ = idx(~to_remove);
self.n_duplicates_ =  accumarray(self.idx_',1)';


