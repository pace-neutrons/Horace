function this= check_file_correct(this,full_file_name)
% the method verifies if the file, provided exist, 
% is the correct nxspe file and
% identifies the location of nxspe data within the hdf5 nexus file
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision: 1 $ ($Date:  $)
%


if ~isa(full_file_name,'char')
    error('LOAD_NXSPE:invalid_argument',' first parameter has to be a file name');                
else
    full_file_name =check_file_exist(full_file_name,{'.nxspe'});         	 
end

if ~H5F.is_hdf5(full_file_name)
    error('LOAD_NXSPE:invalid_argument','file %s is not proper hdf5 file\n',full_file_name);
end

[nexus_folder_name,nxspe_version,nexus_file_structure] = find_root_nexus_dir(full_file_name,'NXSPE');
if isempty(nexus_folder_name)
    error('LOAD_NXSPE:invalid_argument','NXSPE data can not be located withing nexus file file %s\n',full_file_name);
end

if ~strcmp(nxspe_version,'1.1')
    error('LOADER_NXSPE:invalid_argument',' loader nxpse currently supports 1.1 version only but got version: %s\n',nxspe_version);
end
%
%
NXspeInfo   =find_dataset_info(nexus_file_structure,nexus_folder_name,'');
dataset_info=find_dataset_info(NXspeInfo,'data','data');
this.n_detectors    = dataset_info.Dims(2);
this.file_name      = full_file_name;
this.par_file_name  = full_file_name;
this.root_nexus_dir = nexus_folder_name;


