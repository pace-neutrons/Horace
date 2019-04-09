function [n_detectors,en,full_file_name,nexus_dir,ei,psi,nxspe_version]= check_file_correct_get_info(full_file_name)
% the method verifies if the file, provided exist, 
% is the correct nxspe file, identifies the location of nxspe data within the hdf5 nexus file 
% and loads main nxpse file information
%
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
%


if ~ischar(full_file_name)
    error('LOAD_NXSPE:invalid_argument',' first parameter has to be a file name');                
else
    [ok,mess,full_file_name]=check_file_exist(full_file_name,loader_nxspe.get_file_extension());
    if ~ok
        error('LOAD_NXSPE:invalid_argument',mess);
    end
end

if ~H5F.is_hdf5(full_file_name)
    error('LOAD_NXSPE:invalid_argument','file %s is not proper hdf5 file\n',full_file_name);
end

[nexus_dir,nxspe_version,nexus_file_structure] = find_root_nexus_dir(full_file_name,'NXSPE');
if isempty(nexus_dir)
    error('LOAD_NXSPE:invalid_argument','NXSPE data can not be located withing nexus file file %s\n',full_file_name);
end

if ~(strncmp(nxspe_version,'1.1',3) || strncmp(nxspe_version,'1.2',3))
    if strncmp(nxspe_version,'1.0',3)
        nxspe_version='1.0';
    else
        error('LOADER_NXSPE:invalid_argument',' loader nxpse currently supports 1.2/1.0 version only but got version: %s\n',nxspe_version);
    end
else    
   nxspe_version='1.2';
end
%
%
NXspeInfo   =find_dataset_info(nexus_file_structure,nexus_dir,'');
dataset_info=find_dataset_info(NXspeInfo,'data','data');
n_detectors    = dataset_info.Dims(2);


en = hdf5read(full_file_name,[nexus_dir,'/data/energy']);
ei = hdf5read(full_file_name,[nexus_dir,'/NXSPE_info/fixed_energy']);
psi = hdf5read(full_file_name,[nexus_dir,'/NXSPE_info/psi']);



