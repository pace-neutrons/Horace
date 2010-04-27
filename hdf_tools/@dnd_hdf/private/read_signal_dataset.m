function [sqw_data,one_sqw]=read_signal_dataset(one_sqw,varargin)
% one_sqw private method
%
% read the signal, error and npix information from propertly prepared and opened hdf file
%
%
% $Revision$ ($Date$)
%
%bigtic;
%H5D.read(dataset_id, mem_type_id, mem_space_id, file_space_id, plist_id)
data=H5D.read(one_sqw.signal_DSID,one_sqw.signal_DT,'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');      
if nargin>1
    sqw_data = varargin{1};
end
% open attribute;
attr = H5A.open_name (this.signal_DSID,this.signal_dim_ATTR);

% Get dataspace
space = H5A.get_space (attr);
%
% Read the data.
signal_dims=H5A.read (attr, 'H5T_NATIVE_DOUBLE');
% clearn up
%H5D.close (dset);
H5S.close (space);
H5A.close(attr)

one_sqw.signal_dims=fliplr(signal_dims);

sqw_data.s    = reshape(data(1,:),one_sqw.signal_dims);
sqw_data.e    = reshape(data(2,:),one_sqw.signal_dims);    
sqw_data.npix = reshape(data(3,:),one_sqw.signal_dims);   


