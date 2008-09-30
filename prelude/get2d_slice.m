function w = get2d_slice (data, pax1, pax1_lo, pax1_hi, pax2, pax2_lo, pax2_hi);
% Make array of mgenie spectra from the output of gridproj_2d suitable for plotting with mgenie
 
[p1_out,p2_out,ri_out,ei_out] = gridproj_2d(data, pax1, pax1_lo, pax1_hi, pax2, pax2_lo, pax2_hi);

nbin = size(p1_out,1);
nw = size(p2_out,1);

% Get labels for axes
ax=find([1,2,3,4]~=pax1 & [1,2,3,4]~=pax2); % Find plot axes
if ax(1)==1
    xlab = 'h axis';
elseif ax(1)==2
    xlab = 'k axis';
elseif ax(1)==3
    xlab = 'l axis';
elseif ax(1)==4
    xlab = 'energy axis';
end
if ax(2)==1
    ylab = 'h axis';
elseif ax(2)==2
    ylab = 'k axis';
elseif ax(2)==3
    ylab = 'l axis';
elseif ax(2)==4
    ylab = 'energy axis';
end

% Integrated axes:
qdctn={'Q_h'; 'Q_k'; 'Q_l'; 'Eps'};
title{1} = 'TbMnO3';
title{2} = [num2str(pax1_lo),'=<',qdctn{pax1},'=<',num2str(pax1_hi),'  &   ',num2str(pax2_lo),'=<',qdctn{pax2},'=<',num2str(pax2_hi)];
title{3} = ['mgenie_control_x_label = ',xlab];
title{4} = ['mgenie_control_y_label = ',ylab];
ystep = p2_out(2)-p2_out(1);
ystart = p2_out(1) + 0.5*ystep;
title{5} = ['mgenie_control_y_start = ', num2str(ystart)];
title{6} = ['mgenie_control_y_step = ', num2str(ystep)];

% title{ltitle} = ['mgenie_control_x_unitlength = ',slice.f.x_unitlength];
% title{ltitle} = ['mgenie_control_y_unitlength = ',slice.f.y_unitlength];

w=spectrum(p1_out,ri_out(1:nbin-1,1),ei_out(1:nbin-1,1),title,xlab,'Intensity');
if nw>1
    w = repmat(w,1,nw);
    for iw=2:nw
        w(iw)=spectrum(p1_out,ri_out(1:nbin-1,iw),ei_out(1:nbin-1,iw),title,xlab,'Intensity');
    end
end


