function [par,obj] = load_nxspe_par_(obj,return_array,force_reload,getphx)
% method loads detector parameters using properly initiated nxspe class
%
% usage:
%>>[par_data,nxspe_loader_instance]=nxspe_loader_instance.load_nxspe_par(return_array,[keep_existing]);
%
%
% return_array -- if true, return array rather then Horace structure
% keep_existing -- keep existing detector parameters if they have not been loaded in memory
%
root_folder=obj.nexus_root_dir_;
file_name  =obj.par_file_name;
nxspe_ver1 = false;
if get(herbert_config,'log_level')>-1
    if strncmpi(obj.nxspe_version_,'1.0',3)
        warning('LOAD_NXSPE:old_version',...
            ' you are loading detector data from partially supported nxspe data file version 1.0. For this version you should use ASCII par file instead');
        nxspe_ver1=true;
    end
    if strncmpi(obj.nxspe_version_,'1.1',3)
        warning('LOAD_NXSPE:old_version',...
            ' you are loading detector data from nxspe data file version 1.1. This nxspe file contains incorrect detectors sizes for rings, so you should use par file for rings');
    end
end
polar = h5read(file_name,[root_folder,'/data/polar']);

n_det   = numel(polar);
if n_det == obj.n_det_in_par_ && ~isempty(obj.det_par_) && ~force_reload
    par = obj.det_par_;
else
    par     = zeros(6,n_det);
    par(2,:)= polar;
    if nxspe_ver1
        dist = ones(n_det,1);
    else
        dist = h5read(file_name,[root_folder,'/data/distance']);
    end
    par(1,:)= dist;

    par(3,:)= h5read(file_name,[root_folder,'/data/azimuthal']);
    par(6,:)= 1:n_det;
    d_pol   = h5read(file_name,[root_folder,'/data/polar_width']);
    d_azim  = h5read(file_name,[root_folder,'/data/azimuthal_width']);


    par(4,:) = 2*dist.*tand(0.5*d_pol); % get detector's height according to Toby's definition
    par(5,:) = 2*dist.*sind(polar).*tand(0.5*d_azim); % get detector's width according to Toby's definition

    if get(herbert_config,'log_level')>1
        disp(['LOADER_NXSPE:load_par::loaded ' num2str(n_det) ' detector(s)']);
    end
    obj.det_par_ = get_hor_format(par,file_name);
end

if return_array
    if isstruct(par)
        par = get_hor_format(par,'');
    end
    if getphx
        par = a_detpar_loader_interface.convert_par2phx(par);
    end
else
    par = obj.det_par_;
end
obj.n_det_in_par_ = n_det;
