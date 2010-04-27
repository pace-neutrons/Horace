function [sqw_data,this]=read_signals(this,varargin)
% one_sqw private method
%
% read the signal, error and npix information from propertly prepared and opened hdf file
%
%
% $Revision$ ($Date$)
%
%H5D.read(dataset_id, mem_type_id, mem_space_id, file_space_id, plist_id)
data=H5D.read(this.signal_DSID,this.signal_DT,'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');      
if nargin>1&&~isempty(varargin{1})  
    sqw_data = cell2mat(varargin{1});
end

sqw_data.s    = reshape(data(1,:),this.signal_dims);
sqw_data.e    = reshape(data(2,:),this.signal_dims);    
sqw_data.npix = reshape(data(3,:),this.signal_dims);   


