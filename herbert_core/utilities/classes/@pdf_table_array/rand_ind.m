function X = rand_ind (obj, ind)
% Generate random numbers from a set of probability distributions
%
%   >> X = rand_ind  (obj, ind)
%
% The pdfs from which the random numbers are drawn are defined
% by linear interpolation between the array of x coordinates and
% corresponding function values.
%
% Input:
% ------
%   obj         pdf_table_array object
%              (See <a href="matlab:help('pdf_table_array');">pdf_table_array</a> for details)
%
%   ind         Array containing the probability distribution function
%              indices from which a random number is to be taken.
%              min(ind(:))>=1, max(ind(:))<=obj.npdf
%
% Output:
% -------
%   X           Array of random numbers from the distributions, one
%              random number from the pdf for each element of ind.
%              The size of X is the same as ind.

if ~obj.filled
    error('The probability distribution function array is not initialised')
end

np = numel(ind);        % number of random points requested
A_samp = rand(np,1);
Acum_samp = A_samp + (ind(:)-1);

xx = obj.x_; ff = obj.f_; AA = obj.A_; mm = obj.m_; AAcum = obj.Acum_;
ix = upper_index (AAcum, Acum_samp(:));
X = xx(ix) + 2*(A_samp(:) - AA(ix))./...
    (ff(ix) + sqrt(ff(ix).^2 + 2*mm(ix).*(A_samp(:)-AA(ix))));
X = reshape(X,size(ind));
