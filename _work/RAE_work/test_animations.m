%Script to test various animation schemes for Horace

%Sample data:
data_path='C:\Russell\Horace_workshop\SNS_Jan15\Matlab\';
sqw_file=[data_path,'my_real_file.sqw'];
proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.uoffset=[0,0,0,0]; proj.type='rrr';
proj2.u=[1,0,0]; proj2.v=[0,1,0]; proj2.uoffset=[0,0,0,0]; proj2.type='rrr';
proj3.u=[1,1,1]; proj3.v=[-1,1,0]; proj3.uoffset=[0,0,0,0]; proj3.type='rrr';

%Slice we want to work on, to do the tests
my_slice=cut_sqw(sqw_file,proj,[-3,0.05,3],[-1.1,-0.9],[-0.1,0.1],[0,4,280]);
plot(my_slice);

%Split into contributing runs
slice_split=split(my_slice);
plot(slice_split(1))

%1d cut
my_cut=cut(my_slice,[],[100,120]);
plot(my_cut);
cut_split=split(my_cut);
plot(cut_split(1))



%Make animation of these runs
for i=1:numel(slice_split)
    pcolor(slice_split(i).data.s'); shading flat; colormap jet; caxis([0 1]);
    h(i)=getframe;
end
movie(h)

for i=1:numel(slice_split)
    ss=slice_split(i).data.s';
    zz=zeros(size(ss));
    zz=zz./slice_split(i).data.npix';
    zz=zz+1;
    %the above 4 lines are to ensure we have NaNs rather than zeros where
    %there was no data
    pcolor(ss.*zz); shading flat; colormap jet; caxis([0 1]); colormap jet;
%     figure; shading flat; colormap jet; caxis([0 1]); colormap jet;
%     image(ss.*zz); 
    title(['Run number ',num2str(i)]);
    h(i)=getframe;
end

movie(h)

%Play around with frame rate
movie(h,1,5);%Play movie "h" once at a frame rate of 5 per sec

%The above is OK, but we want something a bit more sophisticated, with some
%level of control of the frames
%========================================

%Use videofig (with RAE edit):
videofig(10,@animate_2d,{slice_split,0,2},5,2,[],'Name','Horace Animation')

%Have sorted out how to pass the colour scale, by using a cell array
%argument

videofig(10,@animate_1d,{cut_split},5,2,[],'Name','Horace Animation')

