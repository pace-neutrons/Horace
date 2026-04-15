function[sym_offset,symmetries] = extract_common_group_offset_(symmetries)
%EXTRACT_COMMON_GROUP_OFFSET  check if offset is the same within the array
% of symmetry transformations, extract common offset if some symmetry
% objects in the group does not have offset and throw if
% non-zero offsets in the group are different.
%
% Set up common offset on each element of the group if some
% elements of the group had zero offset.
%
% Inputs:
% symmetries -- array of symop-s. (Should not contain identity)
%
% Returns:
% sym_offset -- offset common for all symmetries provided as input
% symmetries -- Input array of symmetry transformations modified so that
%               each member of this array have common offset set-up.

zer = zeros(3,1);
sym_offset = zer;
n_sym_offsets = 0;
for member=symmetries
    if any(abs(member.offset-zer)>4*eps('double'))
        n_sym_offsets = n_sym_offsets + 1;
        if n_sym_offsets>1
            if any(abs(member.offset-sym_offset)>4*eps('double'))
                error('HORACE:Symop:not_implemented',[ ...
                    'Multiple offsets for group of transformations are not implemented.\n',...
                    'All transformations in a transformation group array must have the same offset\n',...
                    'used by all transformations in the group\n',...
                    'or the same offset for each element of the group']);
            end
        else
            sym_offset  = member.offset;
        end
    end
end
if n_sym_offsets> 0 && n_sym_offsets ~= numel(member)
    % there are offsets set on one or multiple symmetries but
    % some symmetries have zero offsets. This is not allowed as
    % assumed that they all must have the same offset.
    for i =1:numel(symmetries)
        symmetries(i).offset = sym_offset;
    end
end
end