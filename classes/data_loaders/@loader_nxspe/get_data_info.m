function [ndet,en,this]=get_data_info(this)
% get information about an spe file written into hdf5 file previously
% by the function writeSPEas_hdf5(fileName)
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision: 1 $ ($Date:  $)
%

error('LOADER_NXSPE:get_data_info','not yet implemented')
% %
% if ~exist('filename','var')
%     filename=fullfile(this.fileDir,[this.fileName this.fileExt]);
% end
% [nxspe_root_folder,fileinfo] = find_root_nxspeDir(filename);
% 
% 
% fields=spe_hdf_filestructure('data_field_names',2);
% fields=fields{:};
% 
% ndims = fileinfo.GroupHierarchy.Groups.Groups(2).Datasets(3).Dims;
% this.n_detectors = ndims(2);
% this.en          = hdf5read(filename,[nxspe_root_folder{1},'/',fields{2}]);
% this.Ei      =  hdf5read(filename,[nxspe_root_folder{1},'/',fields{1}]);
% if numel(this.en)-1~=ndims(1)
%     error('speData:get_nxspe_header',['incorrect number of detectors while reading file:',filename]);
% end
% this.nxspe_root_folder = nxspe_root_folder;


