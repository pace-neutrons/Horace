%   Data to be fitted: 
%      Single data set only:
%       x   Coordinates of the data points: one of
%           - Vector of x values (1D data) (column or row vector)
%
%           - Two-dimensional array of x coordinates size [npnts,ndims]
%             where npnts is the number of points, and ndims the number
%             of dimensions
%
%           - More generally, an array of any size whose outer dimension
%             gives the coordinate dimension i.e. x(:,:,...:,1) is the array
%             of coordinates along axis 1, x(:,:,...:,2) are those along
%             axis 2 ... to x(:,:,...:,n) are those along the nth axis.
%
%           - A cell array of length n, where x{i} gives the coordinates
%             of all the points on the ith dimension. The arrays can have
%             any size, but they must all have the same size.
%
%       y   Array of the of data values at the points defined by x. Must
%           have the same size as x(:,:,...:,1) if x is an array, or
%           of x{i} if x is a cell array.
%
%       e   Array of the corresponding error bars. Must have same size as y.
%   
%   Alternatively:
%       w   - A structure with fields w.x, w.y, w.e  where x, y, e are arrays
%             as defined above (this is a single dataset)
%
%           - An array of structures fields w(i).x, w(i).y, w(i).e  where x, y, e
%             are arrays as defined above (this defines multiple dataset)
%
%           - A cell array of structures {w1,w2,...}, each structure with fields
%             w1.x, w1.y, w1.e  etc. which correspond to a single dataset
%
%           - An array of objects to be fitted.
%
%           - A cell array of objects to be fitted. Not all the objects need
%             to be of the same class, so long as the function to be fitted
%             is defined as a method for each of the class types.
