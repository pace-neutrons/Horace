function lines = plot_proj_xy()

efix =1400;
det_file_name = 'det_par.par';

proj.u=[1,0,0];
proj.v =[0,1,0];

dets = detectors_par(100,-60,20);
Gon = goniometer();
Crystal =sample([2.87,2.87,2.87],[90,90,90]);

psi_range=[-20,-10,0,10,20,60];
en_transfer=0;
for i=1:numel(psi_range)
        Gon=Gon.set_psi(psi_range(i));

        [u_to_rlu, ucoords] =   calc_projections (Gon,dets,Crystal,efix,en_transfer,proj.u,proj.v);
%extract 2D coordinates of these detectors belonging to the range;
%    [lines{i,1},lines{i,2},lines{i,3}] = split_det(ucoords,block_nums,k_range);
%    [x,y,z] = split_det(ucoords,block_nums,k_range);
      ucoords(1:3,:)=u_to_
       x= ucoords(1,:)*u_to_rlu(1,1);
       y= ucoords(2,:)*u_to_rlu(2,2);       
        plot(x,y,'-g') ; 
end


psi_range = -20:2:60;
en_transfer=[200,500,1000];
cmap = colormap;
nmap = size(cmap,1);
nen  = numel(en_transfer);

col_step = nmap/nen;

hold on;
for j=1:numel(en_transfer);
    col_ind = floor((j-1)*col_step)+1;
    for i=1:numel(psi_range)
        Gon=Gon.set_psi(psi_range(i));

        [u_to_rlu, ucoords] =   calc_projections (Gon,dets,Crystal,efix,en_transfer(j),proj.u,proj.v);
%extract 2D coordinates of these detectors belonging to the range;
%    [lines{i,1},lines{i,2},lines{i,3}] = split_det(ucoords,block_nums,k_range);
%    [x,y,z] = split_det(ucoords,block_nums,k_range);
       x= ucoords(1,:)*u_to_rlu(1,1);
       y= ucoords(2,:)*u_to_rlu(2,2);       
        plot(x,y,'Color',cmap(col_ind,:)) ; 
    end

end
latt = get_reciprocal_lattice(Crystal,3,{[-0.1,0.1]});
xx = latt(:,1)*u_to_rlu(1,1);
yy = latt(:,2)*u_to_rlu(2,2);
scatter(xx,yy,30,[1,0,0],'filled');

Gon=Gon.set_psi(0);
en_transfer=0:50:500;
[u_to_rlu, ucoords] =   calc_projections (Gon,dets,Crystal,efix,en_transfer,proj.u,proj.v);
%extract 2D coordinates of these detectors belonging to the range;
%    [lines{i,1},lines{i,2},lines{i,3}] = split_det(ucoords,block_nums,k_range);
%    [x,y,z] = split_det(ucoords,block_nums,k_range);
x= ucoords(1,:)*u_to_rlu(1,1);
y= ucoords(2,:)*u_to_rlu(2,2);       
%
figure
hold on;
plot(x,y) ; 
scatter(xx,yy,30,[1,0,0],'filled');




