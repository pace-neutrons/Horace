function [grid_size,p,urange]=construct_grid_size_(grid_size_in,urange)
% Return grid_size and bin boundaries from initial grid size specification and data ranges
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

% $Revision: 1240 $ ($Date: 2016-06-07 10:16:18 +0100 (Tue, 07 Jun 2016) $)


% Number of dimensions
[nr,nd]=size(urange);
if nd == 2 && nd ~= nr
    urange = urange';
    nd = size(urange,2);
end

% Create grid size array
if isscalar(grid_size_in)
    grid_size=grid_size_in*ones(1,nd);
elseif numel(grid_size_in)==nd
    if size(grid_size_in,2) == 1
        grid_size_in = grid_size_in';
    end
    grid_size=grid_size_in;
else
    error('APROJECTION:invalid_arguments',...
        'gridsize dimensions %d are not equal do urange dimensions: [%d,%d]',...
        numel(gridsize),size(grid_size_in));
        
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
