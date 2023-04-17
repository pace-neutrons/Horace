function [v1,v2] = ortho_vec(v0)
% The routine returns two vectors, orthogonal to the given one.
%
% The number of elements of the vectors is defined by the number of elements
% of the input vector`
% 
%
[mv,ind] = max(abs(v0));
if mv<eps
    error('HERBERT:ortho_vec:invalid_argument',...
        'Input vector %s has zero size, so is orthogonal to any vector',...
        disp2str(v0));
end

v2 = ones(size(v0));
v2(ind) = 0;
v1 = cross(v0,v2);
v1 = v1/norm(v1);
v2 = cross(v0,v1);
v2 = v2/norm(v2);


