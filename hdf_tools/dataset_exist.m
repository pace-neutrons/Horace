function what_exist=dataset_exist(locationID,DatasetName)
% function checks if a dataset named DatasetName exists under hdf5 location
% specified by locationID
% usage:
% what_exist=dataset_exist(locationID,DatasetName)
% 
% where:
% locationID -- is hdf5 handle to a location e.g. opened file or group of
%                    files
% DatasetName-- sting which identifies a dataset name which existence we
%               are checking
% Returns%
% 1  -- if  a dataset with this name eists or
% 2  -- if there is a group with such name
%
% $Revision$ ($Date$)
%

try
    handle=H5D.open(locationID,DatasetName);
    what_exist = 1;    
    H5D.close(handle);
    return
catch
end
try 
    h1=H5G.open(locationID,DatasetName);
    what_exist = 2;    
    H5G.close(h1);
catch
    what_exist = 0;
end
