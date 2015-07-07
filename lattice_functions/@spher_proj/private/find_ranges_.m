function urange_out=find_ranges_(this,urange_in)
% ------------------------------------------------------------------------
% Get range in output projection axes from the 8 points defined in momentum space by urange_in:
% This gives the maximum extent of the data pixels that can possibly contribute to the output data. 
%[rot,trans]=get_box_transf_(this);

%TODO -- check urange is not shifted
trans =  this.data_u_to_rlu_(1:3,1:3)\(this.ucentre-this.data_uoffset_(1:3));
%this.data_u_to_rlu_\(this.data_uoffset_(1:3)-center)
[x1,x2,x3]=ndgrid(urange_in(:,1)-trans(1),urange_in(:,2)-trans(2),urange_in(:,3)-trans(1));

r  = sqrt(x1.*x1+x2.*x2+x3.*x3);
rmax = max(max(max(r)));

%TODO -- generalize on the case when centre is outside the box
% 2x4 array of limits in output spher_proj. axes
urange_out=[0,-90,-180,urange_in(1,4);rmax,90,180,urange_in(2,4)];
