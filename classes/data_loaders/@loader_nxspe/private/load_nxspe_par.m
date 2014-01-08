function [par,this] = load_nxspe_par(this,return_horace_format)
% method loads detector parametes using properly initiated nxspe class
%
root_folder=this.root_nexus_dir;
file_name  =this.file_name;
if get(herbert_config,'log_level')>-1
    if strncmpi(this.nxspe_version,'1.0',3)
        warning('LOAD_NXSPE:old_version',...
            ' you are loading detector data from partially supported nxspe data file version 1.0. For this version you should use par file instead');
    end
    if strncmpi(this.nxspe_version,'1.1',3)
        warning('LOAD_NXSPE:old_version',...
            ' you are loading detector data from nxspe data file version 1.1. This nxspe file contains incorrect detectors data for rings, so you should use par file for rings');
    end
end

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

if get(herbert_config,'log_level')>0
    disp(['LOADER_NXSPE:load_par::loaded ' num2str(n_det) ' detector(s)']);
end

size_par = size(par);
ndet     = size_par(2);

if return_horace_format
    par = get_hor_format(par,file_name);
end
this.n_detectors = ndet;
this.det_par = par;

end

