function [nodes,en_axis,npoints_in_axes,grid_cell_size] = ...
    calc_bin_nodes_(obj,do3D,halo,data_to_density,density_integr_grid,varargin)
% build 3D or 4D vectors, containing all nodes of the axes_block grid,
% constructed over axes_block axes.
%
% Inputs:
% obj       -- initialized axes_block instance
% do3D      -- if true, return more efficient 3D grid and separate energy
%              axes grid instead of more generic 4D grid over q-dE
%              axes points.
% halo      -- if true, build one-cell width halo around the generated axes
%              grid. Not building halo along energy axes in 3D mode
% dens_interp_grid
%           -- return grid used for density interpolation with points
%              located on the grid cell edges + edges of integrated
%              dimensions
%
% Optional:
% char_cube -- if present, the cube, describing the scale of the grid,
%              to construct the lattice on. The cube here is 3x4(4x2) or
%              3x8 (4x16) array of 3-D or 4-D vectors arranged in
%              columns and describing min/max points or all vertices of
%              cube or hypercube, representing single cell of the grid,
%              defined by the axes_block, or the all points of the whole
%              cube in 3D or 4D space.
%
% Output:
% nodes  -- [3 x nnodes] or [4 x nnodes] aray of grid nodes depending
%           on use3D is true or false.
% en_axis-- 1D array of energy axis grid points.
%
% npoints_in_axes
%        -- 4-elements vector, containing numbers of axes
%           nodes in each of 4 directions
% grid_cell_size
%        -- 4-element vector of characteristic sizes of the grid cell in
%           4 dimensions

char_size = parse_inputs(nargin,varargin{:});
axes = cell(4,1);
%
if isempty(char_size)
    axes(obj.pax) = obj.p(:);
    iint_ax = num2cell(obj.iint',2);
    axes(obj.iax) = iint_ax(:);
    npoints_in_axes = obj.nbins_all_dims+1;
    if halo && ~(data_to_density || density_integr_grid)
        for i=1:4
            step = abs(axes{i}(2)-axes{i}(1));
            axes{i} = [axes{i}(1)-step,axes{i}(:)',axes{i}(end)+step];
            npoints_in_axes(i)= npoints_in_axes(i)+2;
        end
    end
else
    npoints_in_axes = zeros(1,4);
    range = obj.img_range;
    size = range(2,:)'-range(1,:)';
    dNR = floor(size./char_size);
    steps = size./(dNR+1);
    for i=1:4
        if range(1,i)+ steps(i)>=range(2,i)
            axes{i} = [range(1,i),range(2,i)];
            npoints_in_axes(i) = 2;
        else
            if do3D && i==4 % this assumes that dE axis is certainly orthogonal to q-axes
                % and treated differently when nodes contributed to a cut are
                % identified
                npoints_in_axes(i) = obj.nbins_all_dims(4)+1;
                axes{i} = linspace(range(1,i),range(2,i),npoints_in_axes(i));
            else
                if halo && ~(data_to_density || density_integr_grid)
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
grid_cell_size = zeros(4,1);
for i =1:4
    grid_cell_size(i) = min(axes{i}(2:end)-axes{i}(1:end-1));
end

if data_to_density || density_integr_grid
    is_pax = false(4,1);
    is_pax(obj.pax) = true;

    % modify axes to be basis of the interpolation or extrapolation density
    % grid.
    for i=1:4
        if is_pax(i)
            axes{i} = 0.5*(axes{i}(1:end-1)+axes{i}(2:end));
        else % integration axis
            if density_integr_grid
                if numel(axes{i})==2
                    grid_cell_size(i) = obj.img_range(2,i)-obj.img_range(1,i);
                end
                axes{i} = 0.5*(axes{i}(1:end-1)+axes{i}(2:end));

            else  % may be necessary if cell size is provided, not for
                %  default range which is already defined by this formula
                axes{i} = [obj.img_range(1,i),obj.img_range(2,i)];
            end
        end
        npoints_in_axes(i) = numel(axes{i});
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
% process inputs to extract char size in the form of 4D cube. If the input
% numeric array do not satisty the request for beeing 4D characteristic
% cube, throw invalid_argument
%
char_size= [];
if ninputs > 5
    if isnumeric(varargin{1})
        cube = varargin{1};
        cube_size = size(cube);
        if cube_size(1)  ==4
            if cube_size(2) ==2 || cube_size(2) == 2^4
                r0 = min(cube,[],2);
                r1 = max(cube,[],2);
                char_size = r1-r0;
            elseif cube_size(2) == 1
                char_size = cube;
            else
                error('HORACE:axes_block:invalid_argument',...
                    ['characteristic size, if present, should be 4xnNodes', ...
                    ' or 4x1 vector of numeric values. Input size is: [%s]'],...
                    disp2str(cube_size));
            end
        else
            error('HORACE:axes_block:invalid_argument',...
                ['characteristic size, if present, should be 4xnNodes or', ...
                ' 4x1 vector of numeric values. Input size is: [%s]'],...
                disp2str(cube_size));
        end
    else
        error('HORACE:axes_block:invalid_argument',...
            ['characteristic size, if present, should be 4x4xnNodes matrix', ...
            ' or 4x1 vector of numeric values.', ...
            ' Input has wrong type: "%s" and wrong value: "%s"'],...
            class(varargin{1}),disp2str(varargin{1}))
    end
end
