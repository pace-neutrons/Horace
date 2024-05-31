function  [may_contributeND,may_contribute_dE] = may_contribute_(source_proj,...
    source_axes_block,target_proj,targ_axes_block)
% Return the indexes of cells, which may contain the nodes,
% belonging to the target axes block by transforming the source
% coordinate system (SCS) into target coordinate system (TCS)
% and interpolating signal on SCS nodes assuming target coordinate system
% area contains unit signal and signal on SCS is interpolated from unary
% values on TCS and zero values outside of TCS.
%

% build grid with points at bin edges for the target grid and bin centres
% for reference grid
if source_proj.do_3D_transformation_
    [~,dEnodes] = targ_axes_block.get_bin_nodes('-3D','-ngrid','-halo');
    [source_grid,baseEdges]  = source_axes_block.get_bin_nodes('-3D');
    targ_grid_present = ones(size(dEnodes));
    targ_grid_present = nullify_edges(targ_grid_present,size(dEnodes));
    nodes_near = interp1(dEnodes,targ_grid_present,baseEdges,'linear',0);
    may_contribute_dE = nodes_near>0;
    if ~any(may_contribute_dE)
        may_contributeND = [];
        return;
    end
else
    may_contribute_dE = [];
    %targ_nodes = targ_axes_block.get_bin_nodes('-ngrid','-halo');
    source_grid = source_axes_block.get_bin_nodes();
end
bin_range = targ_axes_block.img_range;
bsize = source_axes_block.nbins_all_dims+1;
% convert the coordinates of the bin centres of the reference grid into
% the coordinate system of the target grid.
conv_grid = source_proj.from_this_to_targ_coord(source_grid);

% find the presence of the reference grid centres within the target grid
% cells. If reference grid is present its signal is higher then 0
if source_proj.do_3D_transformation_

    bin_inside = aProjectionBase.bin_inside(conv_grid,bsize(:,1:3),bin_range(:,1:3));
    % but:
    % Instead of combining target nodes, generate new without halo.
    % This may be more efficient as halo would include cells which do not
    % cotribute to final cut at all.
    targ_nodes = targ_axes_block.get_bin_nodes('-3D');
else
    bin_inside = aProjectionBase.bin_inside(conv_grid,bsize,bin_range);

    %targ_nodes = [targ_nodes{1};targ_nodes{2};targ_nodes{3};targ_nodes{4}];
    % see above -- better to generate new nodes.
    targ_nodes = targ_axes_block.get_bin_nodes(); % no halo
end
% verify if target nodes may contribute to the cut, which may be
% the case when source cells are larger and fully contain the cut cells
targ_nodes = target_proj.from_this_to_targ_coord(targ_nodes);
cell_dist = source_axes_block.bin_pixels(targ_nodes);
may_contributeND = bin_inside(:) |cell_dist(:)>0;


function mat = nullify_edges(mat,sze)
% Ugly. Can it be done better?
n_dim = numel(sze);
if numel(sze) == 2 && any(sze == 1)
    n_dim = 1;
end
switch n_dim
    case 1
        mat(1) = 0;
        mat(end)=0;
    case 2
        mat(1,:)  = 0;
        mat(end,:)= 0;
        mat(:,1)  = 0;
        mat(:,end)= 0;
    case 3
        mat(1,:,:)  = 0;
        mat(end,:,:)= 0;
        mat(:,1,:)  = 0;
        mat(:,end,:)= 0;
        mat(:,:,1)  = 0;
        mat(:,:,end)= 0;
    case 4
        mat(1,:,:,:)  = 0;
        mat(end,:,:,:)= 0;
        mat(:,1,:,:)  = 0;
        mat(:,end,:,:)= 0;
        mat(:,:,1,:)  = 0;
        mat(:,:,end,:)= 0;
        mat(:,:,:,1)  = 0;
        mat(:,:,:,end)= 0;
    otherwise
        error('HORACE:aProjectionBase:unsupported_number_of_dimensions',...
            'Can not process %d dimensions',n_dim);
end
