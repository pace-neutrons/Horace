function run_inspector_animate_2d(frame_no,w,clim,axlim)
%
% Make an animation of data from contributing runs in a 2d sqw object.
%
% animate_2d(frame_no,w)
%
% A subroutine of animate_sqw
%
% RAE 30/1/15


%Need various checks to go here to ensure that we have valid inputs

for i=frame_no
    ss=w(i).data.s';
    zz=zeros(size(ss));
    zz=zz./w(i).data.npix';
    zz=zz+1;
    %the above 4 lines are to ensure we have NaNs rather than zeros where
    %there was no data
    
    %2d   
    xx=0.5.*(w(i).data.p{1}(1:end-1)+ w(i).data.p{1}(2:end));
    yy=0.5.*(w(i).data.p{2}(1:end-1)+ w(i).data.p{2}(2:end));
    [XX,YY]=meshgrid(xx,yy);
    
    %NB we need to set the color scale (caxis) from the UI
    pcolor(XX,YY,ss.*zz); shading flat; colormap jet;
    cc=colorbar;%ensure there is a handle to the colorbar
    if ~isempty(clim)
        caxis(clim);
    end
    if ~isempty(axlim)
        axis(axlim);
    end
    ii=IX_dataset_2d(w(i));
    [xlab,ylab,slab]=make_label(ii);
    xlabel(xlab);
    ylabel(ylab);
    clab=ylabel(cc,slab);
    set(clab,'Rotation',-90);
    title(['Run number: ',num2str(i),'; Filename: ',w(i).header.filename,' Psi = ',num2str((180/pi)*w(i).header.psi)]);
end
