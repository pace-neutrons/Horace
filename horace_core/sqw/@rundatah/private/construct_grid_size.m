function [grid_size,p]=construct_grid_size(grid_size_in,pix_range)
% Return grid_size and bin boundaries from initial grid size specification and data ranges
%
%   >> [grid_size,p]=construct_grid_size(grid_size_in,pix_range)
%
% Input:
% ------
%   grid_size_in    Initial grids size definition (scalar, or [1 x nd] array)
%   pix_range       Range of the input data ([2 x nd] array)
%                       [x1_lo,x2_lo,...; x1_hi,x2_hi,...]
%
% Output:
% -------
%   grid_size       Verified or constructed grid size:
%                       - Always a [1 x nd] vector
%                       - grid_size(i)=1 if range is zero
% 	p               Cell array (size=[1,nd]) of column vectors of bin
%                   boundaries for each dimension.



% Number of dimensions
nd=size(pix_range,2);

% Create grid size array
if isscalar(grid_size_in)
    grid_size=grid_size_in*ones(1,nd);
elseif size(grid_size_in,2)==nd
    grid_size=grid_size_in;
else
    error('RUNDATAH:invalid_argument',...
        'Inconsistent sizes between grid_size (%s) and pix_range (%s)',...
        evalc('disp(size(grid_size_in)))'),evalc('disp(size(pix_range)))'))
end

% Get ranges along each axis and construct bin boundaries
% (Do not use linspace, as this does not always guarantee
% the correct number of bin boundaries &/or terminal values)
p=cell(1,nd);
for i=1:nd
    if pix_range(2,i)>pix_range(1,i)
        if grid_size(i)>1
            nb=grid_size(i);
            ind=2:nb;
            p_inner=(pix_range(1,i)*(nb+1-ind)+pix_range(2,i)*(ind-1))'/nb;
            p{i}=[pix_range(1,i);p_inner;pix_range(2,i)];
        else
            p{i}=[pix_range(1,i);pix_range(2,i)];
        end
        p{i}=linspace(pix_range(1,i),pix_range(2,i),grid_size(i)+1)';
    elseif pix_range(2,i)==pix_range(1,i)
        grid_size(i)=1; % set grid size to unity wherever the range is zero
        p{i}=[pix_range(1,i);pix_range(2,i)];
    else
        error('RUNDATAH:invalid_argument',...
            'Must have pix_range(2,:)>pix_range(1,:), got %s',...
            evalc('disp(pix_range))'));
    end
end

