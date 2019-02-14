function [M,vol] = resolution_matrix_from_covariance(C)
% Calculate and return the resolution matrix (and, optionally, volume) from
% the resolution covariance matrix

% The resolution function is a d-dimensional Gaussian
%       R(x) = exp( - (x-x0)'*M*(x-x0)/2 )     
% with 'volume' given by
%       V = (2pi)^(d/2)*sqrt(det(inv(M)))
% But since M == inv(C), we can avoid computing det(inv(M)) and just stick
% with det(inv(inv(C))) = det(C), so
%       V = (2pi)^(d/2)*sqrt(det(C))

% The resolution matrix is the inverse of the covariancem matrix, and
% describes the Gaussian widths of the resolution function
if ismatrix(C)
    assert(issymtol(C,size(C,1)*eps()),'The covariance matrix is not symmetric?!');
    M = inv(C);
else
    s = size(C);
    M = zeros(s);
    tol=s(1)*eps();
    for i=1:prod(s(3:end))
        assert(issymtol(C(:,:,i),tol),'The covariance matrix is not symmetric?!');
        M(:,:,i) = inv( C(:,:,i) );
    end
end
% And the resolution volume is (2pi)^(d/2)*sqrt(det(C))
if nargout > 1
    d = size(C,1);
    pid2 = (2*pi)^(d/2);
    if ismatrix(C)
        vol = pid2*sqrt(det(C));
    else
        s=size(C);
        n=numel(s);
        if 3==n
            vol = zeros(1,s(3));
        else
            vol = permute( zeros(s(3:n)), circshift(3:n+1,1)-2 );
        end
        for i = 1:prod(s(3:n))
            vol(i) = pid2*sqrt(det(C(:,:,i)));
        end
    end
end

end

function sym = issymtol(A,tol)
    sym = sum(sum(abs(A-A'))) < tol;
end