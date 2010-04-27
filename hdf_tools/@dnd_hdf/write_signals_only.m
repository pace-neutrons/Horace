function this = write_signals_only(this,sqw_data)
% one_sqw private method
%
% write the signal, error and npix information to propertly prepared and opened hdf file
%
% side effects:
% sets up the signal dimensions to the dimensions defined in sqw_data and
% number of pixels contributing into the file
%
% $Revision$ ($Date$)
%
wData         = zeros(3,numel(sqw_data.s));
wData(1,:)    = reshape(sqw_data.s,numel(sqw_data.s),1);
wData(2,:)    = reshape(sqw_data.e,numel(sqw_data.e),1);
wData(3,:)    = reshape(sqw_data.npix,numel(sqw_data.npix),1);              

H5D.write (this.signal_DSID, this.signal_DT, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wData);            

% create and associate with the signal dataset an attribute, which
% describes number of pixels in file and write this number to the attribute. 
write_attributes_list(this.signal_DSID,this.dataset_description_fields,this);
% *** > test
%H5F.flush(this.signal_DSID,'H5F_SCOPE_LOCAL');


