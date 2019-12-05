function c = smooth_func_gaussian(width)
% Fills a matrix with a Gaussian function in multiple dimensions
% Output matrix normalised so sum of elements = 1
%
% Syntax:
%   >> c = smooth_func_gaussian(width)
%
%   width   Vector containing full-width half-height (FWHH) in pixels of Gaussian 
%           function along each dimension.
%           The convolution matrix extends to 2% of the peak intensity 
%
%   c       Convolution array

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

f = 0.02;   % convolution matrix will extend to the 2% contour of the multi-dimensional Gaussian

fac = sqrt(log(1/f)/(4*log(2)));    % magnitude f occurs at multiple fac of FWHH
n = floor(fac*max(0,width));        % if any elements of width < 0, assume they should be 0

c=1;
for i=1:length(width)
    if n(i)>0
        % make a Gaussian in the ith dimension with required width and number of elements
        x = linspace(-n(i),n(i),2*n(i)+1);
        g = exp(-(4*log(2))*(x/width(i)).^2);
        % expand the matrix c into the ith dimension
        c = reshape(c,numel(c),1);  % make c a 1D column vector
        c = repmat(c,1,length(g));       % replicate along next dimension
        g = repmat(g,size(c,1),1);       % give weight to each column according to the Gaussian for the ith dimension
        c = c.*g;                        % perform the multiplication
    end
end
c = reshape(c,2*[n,0]+1);   % turn into matrix with the correct extent along each dimension, if necessary
c(find(c<f))=0;         % elements less than f set to zero - will not contribute to convolution
c = c/sum(reshape(c,1,numel(c)));  % normalise so sum of elements is unity

