function X = rand (obj, varargin)
% Generate random numbers from the probability distribution function
%
%   >> X = rand (obj)                % generate a single random number
%   >> X = rand (obj, n)             % n x n matrix of random numbers
%   >> X = rand (obj, sz)            % array of size sz
%   >> X = rand (obj, sz1, sz2,...)  % array of size [sz1,sz2,...]
%
% The pdf from which the random numbers are drawn is defined
% by linear interpolation between the array of x coordinates and
% corresponding function values.
%
% Input:
% ------
%   obj         pdf_table object
%              (See <a href="matlab:help('pdf_table');">pdf_table</a> for details)
%
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   X           Array of random numbers


if ~isscalar(obj)
    error('HERBERT:pdf_table:invalid_argument', 'Method only takes a scalar object')
end
if ~obj.filled
    error('HERBERT:pdf_table:uninitialised', 'The probability distribution function is not initialised')
end

Asamp = rand(varargin{:});

xx = obj.x_; ff = obj.f_; AA = obj.A_; mm = obj.m_;
ix = upper_index (AA, Asamp(:));
X = xx(ix) + 2*(Asamp(:) - AA(ix))./...
    (ff(ix) + sqrt(ff(ix).^2 + 2*mm(ix).*(Asamp(:)-AA(ix))));
X = reshape(X,size(Asamp));

end

