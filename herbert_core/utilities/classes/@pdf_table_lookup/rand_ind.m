function X = rand_ind (obj, varargin)
% Generate random numbers from a set of probability distributions
%
%   >> X = rand_ind (obj, iarray, ind)
%   >> X = rand_ind (obj, ind)
%
% The pdfs from which the random numbers are drawn are defined
% by linear interpolation between the array of x coordinates and
% corresponding function values.
%
% Input:
% ------
%   obj         pdf_table_lookup object
%              (See <a href="matlab:help('pdf_table_lookup');">pdf_table_lookup</a> for details)
%
%   iarray      Scalar index of the original object array from the
%              cell array of object arrays from which the sampling_table
%              was created.
%               If there was only one object array, then this is not
%              necessary (as it assumed iarray=1)
%
%   ind         Array containing the probability distribution function
%              indices from which a random number is to be taken.
%              min(ind(:))>=1, max(ind(:))<=number of objects in the
%              object array selected by iarray
%
% Output:
% -------
%   X           Array of random numbers from the distributions, one
%              random number from the pdf for each element of ind.
%              The size of X is the same as ind.


if ~obj.filled
    error('The probability distribution function lookup is not initialised')
end

if numel(varargin)==2
    iarray = varargin{1};
    if ~isscalar(iarray)
        error('Index to original object array, ''iarray'', must be a scalar')
    end
    ind = varargin{2};
elseif numel(varargin)==1
    if numel(obj.indx_)==1
        iarray = 1;
        ind = varargin{1};
    else
        error('Must give index to the object array from which samples are to be drawn')
    end
else
    error('Insufficient number of input arguments')
end

X = rand_ind (obj.pdf_table_array_, obj.indx_{iarray}(ind));
