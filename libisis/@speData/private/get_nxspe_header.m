function [ndet,en,Ei]=get_nxspe_header(filename)
% get information about an spe file written into hdf5 file previously
% by the function writeSPEas_hdf5(fileName)
%

fileinfo=hdf5info(filename);
hr=fileinfo.GroupHierarchy.Groups.Name;
fields=spe_hdf_filestructure('data_field_names',2);
fields=fields{:};

ndims = fileinfo.GroupHierarchy.Groups.Groups(2).Datasets(3).Dims;
ndet=ndims(2);
en = hdf5read(filename,[hr,'/',fields{2}]);
Ei =  hdf5read(filename,[hr,'/',fields{1}]);
if numel(en)-1~=ndims(1)
    error('speData:get_nxspe_header',['incorrect number of detectors while reading file:',filename]);
end


