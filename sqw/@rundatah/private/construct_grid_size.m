function [grid_size,p]=construct_grid_size(grid_size_in,urange)
% Return grid_size and boin boundaries from initial grid size specification and data ranges
%
%   >> [grid_size,p]=construct_grid_size(grid_size_in,urange)
%
% Input:
% ------
%   grid_size_in    Initial grids size definition (scalar, or [1 x nd] array)
%   urange        	Range of the input data ([2 x nd] array)
%                       [x1_lo,x2_lo,...; x1_hi,x2_hi,...]
%
% Output:
% -------
%   grid_size       Verified or constructed grid size:
%                       - Always a [1 x nd] vector
%                       - grid_size(i)=1 if range is zero
% 	p               Cell array (size=[1,nd]) of column vectors of bin
%                   boundaries for each dimension.

% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


% Number of dimensions
nd=size(urange,2);

% Create grid size array
if isscalar(grid_size_in)
    grid_size=grid_size_in*ones(1,nd);
elseif size(grid_size_in,2)==nd
    grid_size=grid_size_in;
else
    error('Inconsistent dimensions for grid_size and urange')
end

% Get ranges along each axis and construct bin boundaries
% (Do not use linspoace, as this does not alway guarantee the correct number of bin boundaries &/or terminal values)
p=cell(1,nd);
for i=1:nd
    if urange(2,i)>urange(1,i)
        if grid_size(i)>1
            nb=grid_size(i);
            ind=2:nb;
            p_inner=(urange(1,i)*(nb+1-ind)+urange(2,i)*(ind-1))'/nb;
            p{i}=[urange(1,i);p_inner;urange(2,i)];
        else
            p{i}=[urange(1,i);urange(2,i)];
        end
        p{i}=linspace(urange(1,i),urange(2,i),grid_size(i)+1)';
    elseif urange(2,i)==urange(1,i)
        grid_size(i)=1; % set grid size to unity wherever the range is zero
        p{i}=[urange(1,i);urange(2,i)];
    else
        error('Must have urange(2,:)>urange(1,:)')
    end
end
