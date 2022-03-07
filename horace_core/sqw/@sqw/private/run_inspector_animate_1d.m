function run_inspector_animate_1d(frame_no,w,axlim)
%
% Make an animation of data from contributing runs in a 1d sqw object.
%
% animate_1d(frame_no,w)
%
% A subroutine of animate_sqw
%
% RAE 30/1/15


%Need various checks to go here to ensure that we have valid inputs
n_headers = numel(w);

for i=frame_no
    ss=w(i).data.s';
    ee=w(i).data.e';
    ridm = w(i).runid_map;
    run_id = ridm.keys;
    zz=zeros(size(ss));
    zz=zz./w(i).data.npix';
    zz=zz+1;
    %the above 4 lines are to ensure we have NaNs rather than zeros where
    %there was no data

    %1d
    xx=0.5.*(w(i).data.p{1}(1:end-1)+ w(i).data.p{1}(2:end));
    %
    
    errorbar(xx,ss.*zz,sqrt(ee),'or');
    title(sprintf('Frame: %d#%d; RunID: %d; Filename: %s; Psi = %4.1f',...
        i,n_headers,run_id{1},w(i).header.filename,(180/pi)*w(i).header.psi),'Interpreter','none');
    ii=IX_dataset_1d(w(i));
    [xlab,ylab]=make_label(ii);
    xlabel(xlab);
    ylabel(ylab);
    grid on
    if ~isempty(axlim)
        axis(axlim);
    end
end
