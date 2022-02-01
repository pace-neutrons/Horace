function [nodes,en_axis,npoints_in_axes] = calc_bin_nodes_(obj,do3D,halo,varargin)
% build 3D or 4D vectors, containing all nodes of the axes_block grid,
% constructed over axes_block axes.
%
% Inputs:
% obj       -- initialized axes_block instance
% char_cube -- if present, the cube, describing the scale of the grid,
%              to construct the lattice on.
% do3D      -- if true, return more efficient 3D grid and separate energy
%              axes grid instead of more generic 4D grid over q-dE
%              axes points.
% halo      -- if true, build one-cell width halo around the generated axes
%              grid. Not building halo along energy axes in 3D mode
%
% Output:
% nodes  -- [3 x nnodes] or [4 x nnodes] aray of grid nodes depending
%           on use3D is true or false.
% en_axis-- 1D array of energy axis grid points.
%
% npoints_in_axes
%           -- 4-elements vector, containing numbers of axes
%              nodes in each of 4 directions
%

char_size = parse_inputs(nargin,varargin{:});
axes = cell(4,1);
%
if isempty(char_size)
    axes(obj.pax) = obj.p(:);

    iint_ax = num2cell(obj.iint,1);
    axes(obj.iax) = iint_ax(:);
    npoints_in_axes = obj.nbins_all_dims+1;
else
    npoints_in_axes = zeros(1,4);
    range = obj.img_range;
    size = range(2,:)'-range(1,:)';
    dNR = floor(size./(0.5*char_size));
    steps = size./(dNR+1);
    for i=1:4
        if range(1,i)+ steps(i)>=range(2,i)
            axes{i} = [range(1,i),range(2,i)];
            npoints_in_axes(i) = 2;
        else
            if do3D && i==4 % this assumes that dE axis is certainly orthogonal to q-axes
                % and treated differently when nodes contributed to cut are
                % identified
                npoints_in_axes(i) = obj.nbins_all_dims(4)+1;
                axes{i} = linspace(range(1,i),range(2,i),npoints_in_axes(i));
            else
                if halo
                    npoints_in_axes(i) = dNR(i)+3;
                    axes{i} = linspace(range(1,i)-steps(i),...
                        range(2,i)+steps(i),npoints_in_axes(i));
                else
                    npoints_in_axes(i) = dNR(i)+1;                                    
                    axes{i} = linspace(range(1,i),range(2,i),npoints_in_axes(i));
                end
            end
        end
    end
end

en_axis  = axes{4};
if do3D
    [Xn,Yn,Zn] = ndgrid(axes{1},axes{2},axes{3});
    En = en_axis;
else
    [Xn,Yn,Zn,En] = ndgrid(axes{:});
end


if do3D
    nodes = [Xn(:)';Yn(:)';Zn(:)'];
else
    nodes = [Xn(:)';Yn(:)';Zn(:)';En(:)'];
end

function char_size = parse_inputs(ninputs,varargin)
char_size= [];
if ninputs > 3
    if isnumeric(varargin{1})
        cube = varargin{1};
        r0 = min(cube,[],2);
        r1 = max(cube,[],2);
        char_size = r1-r0;
    else
        error('HORACE:axes_block:invalid_argument',...
            'char_size, if present, should be 2x4 vector of numeric values. Input has type: %s values',...
            class(varargin{1}))
    end
end
