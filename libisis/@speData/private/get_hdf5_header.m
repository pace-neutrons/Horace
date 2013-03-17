function [ndet,en,Ei]=get_hdf5_header(filename)
% Get information about an spe hdf5 file written by the function writeSPEas_hdf5
%
%   >> [ndet,en,Ei]=get_hdf5_header(filename)

% TODO this file should check the hdf5 file version
fileinfo=hdf5info(filename);
hr=[fileinfo.GroupHierarchy.Datasets.Dims];
ndet=hr(4);
file_strcut=spe_hdf_filestructure(1);
ver = hdf5read(filename,'spe_hdf_version');
if(ver == 1|| ver == 2)
    en=hdf5read(filename,file_strcut.data_field_names{2});
    if ver==2
        Ei = hdf5read(filename,file_strcut.data_field_names{1});
    else
        Ei =NaN;
    end
else
    error('speData:get_hdf5_header','unsupported spe_hdf file format');
end
