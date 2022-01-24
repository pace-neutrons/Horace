function [nodes,en_axis] = calc_bin_nodes_(obj,varargin)
% build 3D or 4D vectors, containing all nodes of the axes block grid.
%
% Inputs:
% obj       -- initialized axes_block instance
% char_cube -- if present, the cube, describing the scale of the grid,
%              to construct the lattice on.
% use4D     -- the character variable, indicating if to return 4D or 3D
%              points The value of the vaiable is ignored. The routine returns
%              3D or 4D representation of the vector depending on the presence
%              or absence of a character variable
%
% Output:
% nodes  -- [3 x nnodes] or [4 x nnodes] aray of grid nodes depending on use4D
%           variable presence.
% en_axis -- 1D array of energy axis grid points.
%
[use4D,char_size] = parse_inputs(nargin,varargin{:});
axes = cell(4,1);
if isempty(char_size)
    axes(obj.pax) = obj.p(:);
%     for i=1:numel(obj.pax)
%         ax = axes{obj.pax(i)};
%         % binning was done on bin edges, but axes defined on bin centers
%         ax= 0.5*(ax(1:end-1)+ax(2:end));
%         % add last bin boundary to complet binning grid
%         axes{obj.pax(i)} = [ax;ax(end)+ax(2)-ax(1)];
%     end
    
    iint_ax = num2cell(obj.iint,1);
    axes(obj.iax) = iint_ax(:);
else
    range = obj.get_binning_range();
    size = range(2,:)'-range(1,:)';
    dNR = floor(size./(0.5*char_size));
    steps = size./(dNR+1);
    for i=1:4
        if range(1,i)+ steps(i)>range(2,i)
            axes{i} = [range(1,i),range(2,i)];
        else
            axes{i} = range(1,i):steps(i):range(2,i);
        end
    end
end

if use4D
    [Xn,Yn,Zn,En] = ndgrid(axes{:});
else
    [Xn,Yn,Zn] = ndgrid(axes{1},axes{2},axes{3});
    En = axes{4};
end

if use4D
    nodes = [Xn(:)';Yn(:)';Zn(:)';En(:)'];
    en_axis = [];
else
    en_axis = En(:)';
    nodes = [Xn(:)';Yn(:)';Zn(:)'];
end

function [use4D,char_size] = parse_inputs(ninputs,varargin)
use4D = false;
char_size= [];
if ninputs > 1
    if isnumeric(varargin{1})
        cube = varargin{1};
        if ninputs == 3
            use4D = true;
        end
        r0 = min(cube,[],2);
        r1 = max(cube,[],2);
        char_size = r1-r0;
    else
        use4D = true;
    end
end
