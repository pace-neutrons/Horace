function dat = data(obj, in_dat)
% Field containing the dataset(s) to fit.
%
% Valid datasets for multifit are:
%   - A structure with fields w.x, w.y, w.e  where x, y, e are arrays: 
%       x   Coordinates of the data points: one of 
%           - Vector of x values (1D data) (column or row vector) 
%           - Two-dimensional array of x coordinates size [npnts,ndims] 
%             where npnts is the number of points, and ndims the number 
%             of dimensions 
%           - More generally, an array of any size whose outer dimension 
%             gives the coordinate dimension i.e. x(:,:,...:,1) is the array 
%             of coordinates along axis 1, x(:,:,...:,2) are those along 
%             axis 2 ... to x(:,:,...:,n) are those along the nth axis. 
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
%   - An array of structures fields w(i).x, w(i).y, w(i).e  where x, y, e 
%     are arrays as defined above (this defines multiple dataset) 
% 
%   - A cell array of structures {w1,w2,...}, each structure with fields 
%     w1.x, w1.y, w1.e  etc. which correspond to a single dataset 
% 
%   - A cell array of {x y e} vectors / matrices as described above.
%
%   - A cell array of cell arrays {x y e}.
% 
%   - An array of objects to be fitted. 
% 
%   - A cell array of objects to be fitted. Not all the objects need 
%     to be of the same class, so long as the function to be fitted 
%     is defined as a method for each of the class types. 
%
%     In addition to the fit functions, these methods are also required:
%       sigvar_get   - returns the signal, variance and empty mask of
%                      the data. See IX_dataset_1D/sigvar.m for an example.
%       mask         - applies a mask to an input dataset, returning the
%                      masked set. See IX_dataset_1D/mask.m for an example.
%     and either:
%       mask_points  - returns a mask for a dataset like the mask_points_xye()
%                      function. See sqw/mask_points.m for an example
%     or
%       sigvar_getx  - returns the ordinate(s) [bin-centres] of the dataset
%                      See IX_dataset_1D/sigvar_getx.m for an example. 

% In addition to the help text about the data field, we'll also use
% this method function to validate the input datasets as a callback
% called when the user sets the data field of a multifit object.
% In addition to checking the input, it also puts it into a cell array.

% If not called as a callback
if nargin==1
    obj.data
    return
end

% Calls a private function to check the data / put into cell.
[ok,mess,dat] = isvalid_data(in_dat);
if ~ok
    error(mess);
end
