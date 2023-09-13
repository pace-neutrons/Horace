function obj = realign(obj)
%REALIGN align pixels according to the alignment matrix attached to
% pixels and clear alignment information

if ~obj.is_misaligned
    % nothing to do
    return;
end

obj.data(1:3, :) = obj.alignment_matr_ * obj.raw_data(1:3, :);

end
