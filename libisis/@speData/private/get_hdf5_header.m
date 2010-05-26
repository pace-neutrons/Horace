function [ndet,en]=get_hdf5_header(filename)
% get information about an spe file written into hdf5 file previously
% by the function writeSPEas_hdf5(fileName)
fileinfo=hdf5info(filename);
hr=[fileinfo.GroupHierarchy.Datasets.Dims];
ndet=hr(3);
file_strcut=spe_hdf_filestructure();
en=hdf5read(filename,file_strcut.data_field_names{1});
end