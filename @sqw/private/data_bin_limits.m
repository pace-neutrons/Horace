function [val, n] = data_bin_limits (data)
% Get limits of the data in an n-dimensional dataset, that is, find the
% coordinates along each of the axes of the smallest cuboid that contains
% bins with non-zero values of contributing pixels.
%
%   >> [val, n] = data_bin_limits (din)
%
% Input:
% ------
%   din     Input dataset structure
%
% Output:
% -------
%   val     (2 x ndim) array, where ndim = dimension of dataset,containing
%           the lower and upper limits of the bin boundaries of the dataset.
%           isempty(val)=1 if there is no data in the dataset
%   
%   n       (2 x ndim) array containing the lower and upper indices of the 
%           elements along each axis
%           isempty(n)=true if there is no data in the dataset


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


s = sum_dimensions(data.npix);

ndim = length(data.p);
val = zeros(2,ndim);
n = zeros(2,ndim);
for i=1:ndim
    lis = find(s{i}~=0);
    if isempty(lis); val=[]; n=[]; return; end;
    n(1,i)=lis(1);
    n(2,i)=lis(end);
    val(1,i)=data.p{i}(1);
    val(2,i)=data.p{i}(lis(end)+1);
end
