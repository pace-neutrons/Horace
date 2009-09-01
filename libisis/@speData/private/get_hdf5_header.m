function [ndet,en]=get_hdf5_header(filename)
% get information about an spe file written into hdf5 file previously
% by the function writeSPEas_hdf5(fileName)
fileinfo=hdf5info(filename);
hr=[fileinfo.GroupHierarchy.Datasets.Dims];
ndet=hr(3);
en=hdf5read(filename,'Energy_Bin_Boundaries');
end