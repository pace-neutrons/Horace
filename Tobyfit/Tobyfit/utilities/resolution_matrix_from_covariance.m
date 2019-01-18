function M = resolution_matrix_from_covariance(C)
% The resolution matrix is the inverse of the covariancem matrix:
if ismatrix(C)
    M = inv(C);
else
    s = size(C);
    M = zeros(s);
    for i=1:prod(s(3:end))
        M(:,:,i) = inv( C(:,:,i) );
    end
end
end
