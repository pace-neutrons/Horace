function is = is_range_wider(range1,range2)
% Function accepts two ranges defined by 2xN matrices containing min/max
% values, and returns true if first range surrounds the second one, i.e. 
% all minimas of first range are smaller or equal to minimas of the second
% ranges and all maximas of the first range are larger or equal to maximas
% of the first range
%
% Input:
% range1     -- 2xN matrix with each column containing [min1;max1] value
% range1     -- another 2xN matrix with each column containing [min2;max2] value
%
% Returns:
% true if first matrix surrounds second matrix or false otherwise
if any(size(range1)~=size(range2)) || size(range1,1) ~=2
    error('HORACE:utilities:invalid_argument', ...
        ['The ranges sizes needs to be the same and have form: 2xN.\n' ...
        'Size of range1 is: %s and size of range2 is %s'], ...
        disp2str(range1),disp2str(range2));
end

is = all(range1(1,:)<=range2(1,:))&&all(range1(2,:)>=range2(2,:));
