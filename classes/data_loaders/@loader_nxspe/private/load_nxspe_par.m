function par = load_nxspe_par(this)
% method loads detector parametes using properly initiated nxspe class
%
root_folder=this.root_nexus_dir;
file_name  =this.file_name; 

dist    = hdf5read(file_name,[root_folder,'/data/distance']);
n_det   = numel(dist);
par     = zeros(6,n_det);
par(1,:)= dist;
par(2,:)= hdf5read(file_name,[root_folder,'/data/polar']);
par(3,:)= hdf5read(file_name,[root_folder,'/data/azimuthal']);
par(6,:)= 1:n_det;
d_pol   = hdf5read(file_name,[root_folder,'/data/polar_width']); 
d_azim  = hdf5read(file_name,[root_folder,'/data/azimuthal_width']);  

% not clear what exactly this should be as there are no precize
% correspondance between two without knowing detector's direction;
par(4,:) = d_pol .*dist;
par(5,:) = d_azim.*dist;
end

