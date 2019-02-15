% Calculate and return the resolution matrix (and, optionally, volume) from
% the resolution covariance matrix
%
% The calculation is performed using mex C++ code that evaluates the
% Faddeev-LeVerrier algorithm to compute the inverse and determinant of C.
% https://en.wikipedia.org/wiki/Faddeev%E2%80%93LeVerrier_algorithm
% The mex code is parallelized with OpenMP, and on a machine with six
% physical cores is ~45x faster than native MATLAB inv() and det(), and
% ~60x faster than a MATLAB implementation of the same algorithm.
%
% The resolution function is a d-dimensional Gaussian
%       R(x) = exp( - (x-x0)'*M*(x-x0)/2 )     
% with 'volume' given by
%       V = (2pi)^(d/2)*sqrt(det(inv(M)))
% But since M == inv(C), we can avoid computing det(inv(M)) and just stick
% with det(inv(inv(C))) = det(C), so
%       V = (2pi)^(d/2)*sqrt(det(C))

% The resolution matrix is the inverse of the covariancem matrix, and
% describes the Gaussian widths of the resolution function

function [M,vol]=cov2resmat(C)
config = hor_config(); % Move to a tobyfit_config()?
usemex=config.use_mex;
if usemex
    d = size(C,1);
    assert(size(C,2)==d,'C should be one or more square matricies.');
    m = size(C,3); % might be one, which should be OK

    pid2 = (2*pi)^(d/2);

    castto = 'UInt64';
    d = cast(d,castto);
    m = cast(m,castto);

    castdbl ='double';
    C = cast(C,castdbl);
    pid2 = cast(pid2,castdbl);
    
    try
    if nargout < 2
        % We can skip copying the volume array back to MATLAB if it isn't
        % requested:
        M = cppResolutionMatrixFromCovariance(d,m,C,pid2);
    else
        [M,vol]= cppResolutionMatrixFromCovariance(d,m,C,pid2);
    end
    catch
        warning('Executing mex file failed.')
        usemex=false;
    end
end
if ~usemex
    [M,vol]=resolution_matrix_from_covariance(C);
end
end
