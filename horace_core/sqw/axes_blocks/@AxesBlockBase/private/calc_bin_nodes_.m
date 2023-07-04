function [nodes,en_axis,npoints_in_axes,bin_volume] = ...
    calc_bin_nodes_(obj,call_nargout,do3D,halo,bin_edges,bin_centre, ...
    dens_interp, plot_edges,...
    axes_only,ngrid_form,hull,varargin)
% build 3D or 4D vectors, containing all nodes of the AxesBlockBase grid,
% constructed over AxesBlockBase axes.
%
% Inputs:
% obj       -- initialized AxesBlockBase instance
% call_nargout
%           -- number of output argument this the class method was called
%              with. Used to check if cell volume calculations are necessary
% do3D      -- if true, return more efficient 3D grid and separate energy
%              axes grid instead of more generic 4D grid over q-dE
%              axes points.
% halo      -- if true, build one-cell width halo around the generated axes
%              grid. Not building halo along energy axes in 3D mode
% bin_edges -- if true, return grid containing bin edges
% dens_interp
%           -- if true, return grid used to define density, bin centres for
%              projection axes and bin edges of integrated dimensions.
% plot_edges-- if true, return bin_edges as used for plotting dispersion
%              i.e. bin edges for plot axes and bin centers for integration
%              axes
% bin_centre
%           -- if true, return grid used for integration by summation in
%              centre-points, namely, points are in the centre of cells and
%              integration dimensions
% axes_only -- if true, do not build n-d grid but return only grid points
%              in each 4 directions
% ngrid_form
%           -- if true, return result as cellarray of arrays, as ngrid
%              function generates
% hull      -- if true, return only boundary nodes of the grid.
%              If halo is also true, return edge nodes and halo nodes.
%
% Optional:
% char_cube -- if present, the cube, describing the scale of the grid,
%              to construct the lattice on. The cube here is 3x4(4x2) or
%              3x8 (4x16) array of 3-D or 4-D vectors arranged in
%              columns and describing min/max points or all vertices of
%              cube or hypercube, representing single cell of the grid,
%              defined by the AxesBlockBase, or the all points of the whole
%              cube in 3D or 4D space.
% grid_nnodes_multiplier
%           -- if present, used instead of char_cube to produce grid, which
%             is bigger then the original grid by multiplying the original
%             grid
%
%
% Output:
% nodes  -- [3 x nnodes] or [4 x nnodes] aray of grid nodes depending
%           on use3D is true or false.
% en_axis-- 1D array of energy axis grid points.
%
% npoints_in_axes
%        -- 4-elements vector, containing numbers of axes
%           nodes in each of 4 directions
% bin_volume
%        -- either the value of volume of a bin if all bin sizes are equal or
%           vector of bin volumes for the grid returned grid if axes bin
%           volumes differ

n_pos_arg = 11; % number of positional arguments always present as inputs (excluding varargin)
if bin_centre && (bin_edges || plot_edges)
    error('Horace:AxesBlockBase:invalid_argument',...
        '"-bin_centre" can not be used with "-bin_edges" or "-plot_edges" keys')
end
if bin_edges && plot_edges
    error('Horace:AxesBlockBase:invalid_argument',...
        '"-bin_edges" can not be used together with "-plot_edges" keys')

end
if ngrid_form && hull
    error('HORACE:AxesBlockBase:invalid_argument',...
        '"-hull" and "-grid_form" parameters can not be used together');
end
grid_nnodes_multiplier = parse_inputs(n_pos_arg,nargin,varargin{:});

axes = cell(4,1);
%
if isempty(grid_nnodes_multiplier)
    axes(obj.pax) = obj.p(:);
    iint_ax = num2cell(obj.iint',2);
    axes(obj.iax) = iint_ax(:);
    npoints_in_axes = obj.nbins_all_dims+1;
    if halo
        for i=1:4
            axes{i} = build_ax_with_halo(obj.max_img_range_(:,i),axes{i});
            npoints_in_axes(i)= numel(axes{i});
        end
    end
else
    range = obj.img_range;
    npoints_in_axes = zeros(1,4);
    for i=1:4 % this mode is used for data interpolation, so we need to
        % keep bin centers, where the base interpolating function is
        % defined unchanged
        ax = linspace(range(1,i),range(2,i),obj.nbins_all_dims(i)+1);
        if grid_nnodes_multiplier(i) == 2
            cent = 0.5*(ax(1:end-1)+ax(2:end));
            ax = sort([ax,cent]);
        elseif grid_nnodes_multiplier(i) > 2
            bin_cells = cell(1,obj.nbins_all_dims(i));
            for j=1:obj.nbins_all_dims(i)
                bin_cells{j} = linspace(ax(j),ax(j+1),grid_nnodes_multiplier(i)+1);
            end
            bin_cells = cell2mat(bin_cells);
            ax = unique(bin_cells);
        end
        if halo
            axes{i} = build_ax_with_halo(obj.max_img_range_(:,i),ax{i});
        else
            axes{i} = ax(:)';
        end
        npoints_in_axes(i) = numel(axes{i});
    end
end
if call_nargout > 3
    bin_volume = obj.get_bin_volume(axes);
else
    bin_volume  = [];
end

if bin_centre || dens_interp || plot_edges
    is_pax = false(4,1);
    is_pax(obj.pax) = true;

    % modify axes to be basis of the interpolation or extrapolation density
    % grid.
    for i=1:4
        if is_pax(i)
            if ~plot_edges
                axes{i} = 0.5*(axes{i}(1:end-1)+axes{i}(2:end));
            end
        else % integration axis
            if dens_interp  % may be necessary if cell size is provided, not for
                %  default range which is already defined by this formula
                axes{i} = [obj.img_range(1,i),obj.img_range(2,i)];
            else
                axes{i} = 0.5*(axes{i}(1:end-1)+axes{i}(2:end));
            end
        end
        npoints_in_axes(i) = numel(axes{i});
    end
end
en_axis  = axes{4};
ax_hull = axes;
if hull
    for i=1:4
        ax = ax_hull{i};
        if halo
            ax_hull{i} = [ax(1:2),ax(end-1:end)];
        else
            if plot_edges && ~is_pax(i)
                ax_hull{i} = 0.5*(ax(1)+ax(end));
            else
                ax_hull{i} = [ax(1),ax(end)];
            end
        end
    end
end

if axes_only
    if do3D
        nodes = {ax_hull{1},ax_hull{2},ax_hull{3}};
    else
        nodes = {ax_hull{1},ax_hull{2},ax_hull{3},ax_hull{4}};
    end
    return;
end
if do3D
    if hull
        [Xn1,Yn1,Zn1] = ndgrid(ax_hull{1},axes{2},axes{3});
        [Xn2,Yn2,Zn2] = ndgrid(axes{1},ax_hull{2},axes{3});
        [Xn3,Yn3,Zn3] = ndgrid(axes{1},axes{2},ax_hull{3});

        Xn = [Xn1(:);Xn2(:);Xn3(:)]';
        Yn = [Yn1(:);Yn2(:);Yn3(:)]';
        Zn = [Zn1(:);Zn2(:);Zn3(:)]';
    else
        [Xn,Yn,Zn] = ndgrid(axes{1},axes{2},axes{3});
    end
    En = en_axis;
else
    if hull
        if plot_edges
            [Xn,Yn,Zn,En] = ndgrid(ax_hull{:});
        else
            [Xn1,Yn1,Zn1,En1] = ndgrid(ax_hull{1},axes{2},axes{3},axes{4});
            [Xn2,Yn2,Zn2,En2] = ndgrid(axes{1},ax_hull{2},axes{3},axes{4});
            [Xn3,Yn3,Zn3,En3] = ndgrid(axes{1},axes{2},ax_hull{3},axes{4});
            [Xn4,Yn4,Zn4,En4] = ndgrid(axes{1},axes{2},axes{3},ax_hull{4});

            Xn = [Xn1(:);Xn2(:);Xn3(:);Xn4(:)]';
            Yn = [Yn1(:);Yn2(:);Yn3(:);Yn4(:)]';
            Zn = [Zn1(:);Zn2(:);Zn3(:);Zn4(:)]';
            En = [En1(:);En2(:);En3(:);En4(:)]';
        end
    else
        [Xn,Yn,Zn,En] = ndgrid(axes{:});
    end
end

if do3D
    if ngrid_form
        nodes = {Xn,Yn,Zn};
    else
        nodes = [Xn(:)';Yn(:)';Zn(:)'];
    end
else
    if ngrid_form
        nodes = {Xn,Yn,Zn,En};
    else
        nodes = [Xn(:),Yn(:),Zn(:),En(:)]';
    end
end

function  axes = build_ax_with_halo(range,axes)
% Build axes with halo which does not exceed
% the allowed image ranges
%
L_step    = abs(axes(2)-axes(1));
min_pos = axes(1)-L_step;
if min_pos < range(1)
    if abs(range(1))<eps
        min_pos = -eps;
    else
        min_pos = range(1)*(1+eps);
    end
end
R_step = abs(axes(end)-axes(end-1));
max_pos = axes(end)+R_step;
if max_pos > range(2)
    if abs(range(2))<eps
        max_pos = eps;
    else
        max_pos = range(2)*(1+eps);
    end
end
axes = [min_pos,axes(:)',max_pos];

function nnodes_multiplier = parse_inputs(noptions,ninputs,varargin)
% process inputs to extract char size in the form of 4D cube. If the input
% numeric array do not satisty the request for beeing 4D characteristic
% cube, throw invalid_argument
%
nnodes_multiplier = [];
if ninputs > noptions
    if isnumeric(varargin{1})
        nnodes_multiplier = round(varargin{1});
        nnodes_multiplier = nnodes_multiplier(:)';
        if numel(nnodes_multiplier) == 1
            nnodes_multiplier = ones(1,4)*nnodes_multiplier;
        end
        nnodes_multiplier(nnodes_multiplier<1) = 1;
        if numel(nnodes_multiplier)~=4
            error('HORACE:AxesBlockBase:invalid_argument',...
                ['nnodes multipler should be 1x4 vector or single value.\n', ...
                ' Input size is: [%s]'],...
                disp2str(size(varargin{1})));
        end
    else
        error('HORACE:AxesBlockBase:invalid_argument',...
            ['nodes_multiplier, if present, should be single numeric value', ...
            ' or 4x1 vector of numeric values.\n', ...
            ' Input has wrong type: "%s" and wrong value: "%s"'],...
            class(varargin{1}),disp2str(varargin{1}))
    end
end
