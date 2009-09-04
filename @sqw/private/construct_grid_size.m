function [grid_size,p]=construct_grid_size(grid_size_in,urange,nd)
% the function verifies the grid sizes, sets defaults if grid size is wrong
% and fills in the bins boundaries for grid axis
%
% inputs:
% grid_size_in  --  initial grdis size guess
% urange        --  range of the input data
% nd            --  number of data dimentions; should be equal to
%                   size(grid_size,2) if grid_size is defined. defines the
%                   grid_size otherwise;
% outputs:
% grid_size     -- verified or constructed grid size
% p             -- bin coordinates;
%
% Construct grid_size array if necessary
%
% $Revision$ ($Date$)
%
if isscalar(grid_size_in)||size(grid_size_in,2)~=nd
    grid_size=grid_size_in*ones(1,nd);
else
    grid_size=grid_size_in;
end

% Get ranges along each axis and construct bin boundaries
grid_size(urange(2,:)==urange(1,:))=1;  % set grid size to unity wherever the range is zero
p=cell(1,nd);
for i=1:nd
    p{i}=linspace(urange(1,i),urange(2,i),grid_size(i)+1);
end
end