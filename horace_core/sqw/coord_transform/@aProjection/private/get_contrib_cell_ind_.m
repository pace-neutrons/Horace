function  contrib_ind = get_contrib_cell_ind_(source_proj,...
    cur_axes_block,targ_proj,targ_axes_block)
% Return the indexes of cells, which may contain the nodes,
% belonging to the target axes block by
%
% Transforming the target coordinate system (TCS) into source coordinate system
% and binning TCS nodes into source coordinate system bins.
%
%


% build bin edges for the target grid and bin centres for reference grid
if source_proj.do_3D_transformation_
    [targ_nodes,dEnodes] = targ_axes_block.get_bin_nodes('-3D','-ngrid','-halo');
    [ch_grid,baseEdges]  = cur_axes_block.get_bin_nodes('-bin_centre','-3D');
    presence_mark = ones(size(dEnodes));
    presence_mark = nullify_edges(presence_mark,size(dEnodes));    
    nodes_near = interp1(dEnodes,presence_mark,baseEdges,'linear',0);
    may_contribure = nodes_near>0;
    if ~any(may_contribure)
        contrib_ind = [];
        return;
    end
else
    targ_nodes = targ_axes_block.get_bin_nodes('-ngrid','-halo');
    ch_grid = cur_axes_block.get_bin_nodes('-bin_centre');
end
szn = size(targ_nodes{1});
presence_mark = ones(szn);
presence_mark = nullify_edges(presence_mark,szn);

%nodes_present = ones(size(targ_nodes{1}));
% convert the coordinates of the bin centres of the reference grid into
% the coordinate system of the target grid.
conv_grid = source_proj.from_this_to_targ_coord(ch_grid);

% find the presence of the reference grid centres within the target grid
% cells.
if source_proj.do_3D_transformation_
    interp_ds = interpn(targ_nodes{1},targ_nodes{2},targ_nodes{3},presence_mark,...
        conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)', 'linear',0);

    contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
        interp_ds(:)>eps(single(1)),may_contribure);
else
    interp_ds = interpn(targ_nodes{1},targ_nodes{2},targ_nodes{3},targ_nodes{4},presence_mark,...
        conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)',conv_grid(4,:)', 'linear',0);
    contrib_ind = find(interp_ds > eps(single(1)));
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
        error('HORACE:aProjection:unsupported_number_of_dimensions',...
            'Can not process %d dimensions',n_dim);
end
