function range_out=find_ranges_(this,range_in)
% ------------------------------------------------------------------------
% Get range in output projection axes from the 8 points defined in momentum space by pix_range_in:
% 
% This gives the maximum extent of the data pixels that can possibly contribute to the output data. 
[rot,trans]=get_box_transf_(this);


[x1,x2,x3]=ndgrid(range_in(:,1)-trans(1),range_in(:,2)-trans(2),range_in(:,3)-trans(3));
vertex_in=[x1(:)';x2(:)';x3(:)'];
vertex_out = rot*vertex_in;
range_out=[[min(vertex_out,[],2)';max(vertex_out,[],2)'],range_in(:,4)];  % 2x4 array of limits in output proj. axes
