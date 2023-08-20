function  obj = apply_alignment(obj)
%APPLY_ALIGNMENT align pixels according to the alignment matrix attached to
% pixels and clear alignment information

if ~obj.is_misaligned
    % nothing to do
    return;
end
obj.data_(1:3,:)       = obj.alignment_matr_*obj.data_(1:3,:);
obj.data_range_(:,1:3) = obj.pix_minmax_ranges(obj.data_(1:3,:));
obj.alignment_matr_ = eye(3);
obj.is_misaligned_   = false;