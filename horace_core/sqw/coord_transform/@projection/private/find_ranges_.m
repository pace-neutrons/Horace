function urange_out=find_ranges_(this,urange_in)
% ------------------------------------------------------------------------
% Get range in output projection axes from the 8 points defined in momentum space by urange_in:
% This gives the maximum extent of the data pixels that can possibly contribute to the output data. 
[rot,trans]=get_box_transf_(this);


[x1,x2,x3]=ndgrid(urange_in(:,1)-trans(1),urange_in(:,2)-trans(2),urange_in(:,3)-trans(3));
vertex_in=[x1(:)';x2(:)';x3(:)'];
vertex_out = rot*vertex_in;
urange_out=[[min(vertex_out,[],2)';max(vertex_out,[],2)'],urange_in(:,4)];  % 2x4 array of limits in output proj. axes
