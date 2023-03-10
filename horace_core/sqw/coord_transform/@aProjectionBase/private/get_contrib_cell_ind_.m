function  contrib_ind = get_contrib_cell_ind_(source_proj,...
    cur_axes_block,target_proj,targ_axes_block)
% Return the indexes of cells, which may contain the nodes,
% belonging to the target axes block by transforming the source
% coordinate system (SCS) into target coordinate system (TCS)
% and interpolating signal on SCS nodes assuming target coordinate system
% area contains unit signal and signal on SCS is interpolated from unary
% values on TCS and zero values outside of TCS.
%

% build bin edges for the target grid and bin centres for reference grid
if source_proj.do_3D_transformation_
    [targ_nodes,dEnodes] = targ_axes_block.get_bin_nodes('-3D','-ngrid','-halo');
    [source_grid,baseEdges]  = cur_axes_block.get_bin_nodes('-bin_centre','-3D');
    targ_grid_present = ones(size(dEnodes));
    targ_grid_present = nullify_edges(targ_grid_present,size(dEnodes));
    nodes_near = interp1(dEnodes,targ_grid_present,baseEdges,'linear',0);
    may_contribute = nodes_near>0;
    if ~any(may_contribute)
        contrib_ind = [];
        return;
    end
else
    targ_nodes = targ_axes_block.get_bin_nodes('-ngrid','-halo');
    source_grid = cur_axes_block.get_bin_nodes('-bin_centre');
end
% define unit signal on the edges of the target grid and zeros at "halo"
% points surrounding the target grid
szn = size(targ_nodes{1});
targ_grid_present = ones(szn);
targ_grid_present = nullify_edges(targ_grid_present,szn);

% convert the coordinates of the bin centres of the reference grid into
% the coordinate system of the target grid.
conv_grid = source_proj.from_this_to_targ_coord(source_grid);

% find the presence of the reference grid centres within the target grid
% cells.
if source_proj.do_3D_transformation_
    interp_ds = interpn(targ_nodes{1},targ_nodes{2},targ_nodes{3},targ_grid_present,...
        conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)', 'linear',0);
    targ_nodes = targ_axes_block.get_bin_nodes('-3D','-hull');
else
    interp_ds = interpn(targ_nodes{1},targ_nodes{2},targ_nodes{3},targ_nodes{4},targ_grid_present,...
        conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)',conv_grid(4,:)', 'linear',0);
    targ_nodes = targ_axes_block.get_bin_nodes('-hull');
end
% verify if hull nodes may contribute to the cut, which may be 
% the case when source cells are large and fully contain the cut cells
targ_nodes = target_proj.from_this_to_targ_coord(targ_nodes);
cell_dist = cur_axes_block.bin_pixels(targ_nodes);
may_contributeND = interp_ds(:)>eps(single(1))|cell_dist(:)>0;

if source_proj.do_3D_transformation_
    contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
        may_contributeND ,may_contribute);
else
    contrib_ind = find(may_contributeND);
end



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
