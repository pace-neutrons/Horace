function hdf5_file_ID=open_or_create(fileName)
% function tryes to create an hdf5 file fileName if the file does not exist
% or opens it if it does exist
%
% returns correct hdf file ID
%
% $Revision$ ($Date$)
%
if exist(fileName,'file')
     if H5F.is_hdf5(fileName)
         hdf5_file_ID = H5F.open(fileName, 'H5F_ACC_RDWR', 'H5P_DEFAULT');    
     else
         error('HORACE:hdf_tools','Attempting to open non-hdf5 file %s as hdf5 file',fileName);
     end
else
      hdf5_file_ID = H5F.create(fileName,'H5F_ACC_TRUNC','H5P_DEFAULT', 'H5P_DEFAULT');            
end

