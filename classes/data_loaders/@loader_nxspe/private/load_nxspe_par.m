function [par,this] = load_nxspe_par(this,return_array,varargin)
% method loads detector parametes using properly initiated nxspe class
%
% usage:
%>>[par_data,nxspe_loader_instance]=nxspe_loader_instance.load_nxspe_par(return_array,[keep_existing]);
%
%
% return_array -- if true, return array rather then Horace structure
% keep_existing -- keep existing detector parameters if they have not been loaded in memory
%
root_folder=this.root_nexus_dir;
file_name  =this.file_name;
nxspe_ver1 = false;
if get(mslice_config,'log_level')>-1
    if strncmpi(this.nxspe_version,'1.0',3)
        warning('LOAD_NXSPE:old_version',...
            ' you are loading detector data from partially supported nxspe data file version 1.0. For this version you should use par file instead');
        nxspe_ver1=true;
    end
    if strncmpi(this.nxspe_version,'1.1',3)
        warning('LOAD_NXSPE:old_version',...
            ' you are loading detector data from nxspe data file version 1.1. This nxspe file contains incorrect detectors data for rings, so you should use par file for rings');
    end
end
polar = hdf5read(file_name,[root_folder,'/data/polar']);
n_det   = numel(polar);
par     = zeros(6,n_det);
par(2,:)= polar;
if nxspe_ver1
    dist = ones(n_det,1);
else
    dist = hdf5read(file_name,[root_folder,'/data/distance']);
end
par(1,:)= dist;

par(3,:)= hdf5read(file_name,[root_folder,'/data/azimuthal']);
par(6,:)= 1:n_det;
d_pol   = hdf5read(file_name,[root_folder,'/data/polar_width']);
d_azim  = hdf5read(file_name,[root_folder,'/data/azimuthal_width']);

% not clear what exactly this should be as there are no precize
% correspondance between two without knowing detector's direction;
par(4,:) = d_pol .*dist; % get detector's height
par(5,:) = d_azim.*dist; % get detecor's width

if get(mslice_config,'log_level')>0
    disp(['LOADER_NXSPE:load_par::loaded ' num2str(n_det) ' detector(s)']);
end

size_par = size(par);
ndet     = size_par(2);

this.det_par_stor = get_hor_format(par,file_name);
if ~return_array
    par = this.det_par_stor;
end
this.n_detindata_stor = ndet;
