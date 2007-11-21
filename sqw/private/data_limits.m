function [val, n] = data_limits (din)
% Get limits of the data in an n-dimensional dataset, that is, find the
% coordinates along each of the axes of the smallest cubiod that contains
% bins with non-zero values of contributing pixels.
%
% Syntax:
%   >> [val, n] = data_limits (din)
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
%           isempty(n)=1 if there is no data in the dataset

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

nin = ~isnan(din.s);

s = sum_dimensions(nin);

ndim = length(din.pax);
val=zeros(2,ndim);
n=zeros(2,ndim);
for i=1:ndim
    nam = ['p',num2str(i)];
    lis = find(s.(nam)~=0);
    if isempty(lis); val=[]; n=[]; return; end;
    n(1,i)=lis(1);
    n(2,i)=lis(end);
    val(1,i)=din.(nam)(1);
    val(2,i)=din.(nam)(lis(end)+1);
end
    
    
        

