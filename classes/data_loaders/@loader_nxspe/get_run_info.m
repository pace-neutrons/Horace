function [ndet,en,this]=get_run_info(this)
% Get number of detectors defined by the class or in ascii par or phx file
%   >> ndet = load_par_info(filename)
%
% $Revision$ ($Date$)
%
if isempty(this.n_detectors)

    [nexus_folder_name,nxspe_version,nexus_file_structure] = find_root_nexus_dir(full_file_name,'NXSPE');
    if isempty(nexus_folder_name)
        error('LOAD_NXSPE:invalid_argument','NXSPE data can not be located withing nexus file file %s\n',full_file_name);
    end
%
%
    dataset_info =find_dataset_info(nexus_file_structure,'data','data');
    this.n_detectors    = dataset_info.Dims(2);


else
	ndet=this.n_detectors;
    if nargout==1
        return;
    end
end
%
filename=this.file_name;
if isempty(filename)
    error('LOADER_NXSPE:problems_with_file',' get_par_info needs nxspe file to be defined');
end

    
if isempty(this.en)
    this.en = hdf5read(filename,[this.root_nexus_dir,'/data/energy']);
end
en = this.en;




