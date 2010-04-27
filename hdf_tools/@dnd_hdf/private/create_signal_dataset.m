function this=create_signal_dataset(this)
% function defines the HDF5 parameters and properties for signal error
% and npix datasets
% it also creates places for these datasets hdf file.
%
% $Revision$ ($Date$)
%

avail = H5Z.filter_avail('H5Z_FILTER_DEFLATE');
if ~avail
    error ('HORACE:hdf_tools','define_sqw_datasets:->gzip filter not available.');
end

% Signal dataset. Has to be consistent with the structure supplied to write
% signal, error and npix data in read/write commands;
 this = build_signal_datatype(this);
 % 
 %  Define dataspace as 1D array to accelerate access
 %
 rank = 1;
 dims = prod(this.signal_dims);
 this.signal_Space=H5S.create_simple (rank,dims,[]);
 
 %
 % Define dataset properties
 %
 this.signal_DSProperties= H5P.create('H5P_DATASET_CREATE');
 H5P.set_chunk(this.signal_DSProperties, fliplr(this.signal_DS_chunk));
 H5P.set_deflate(this.signal_DSProperties, this.signal_DS_compression);



% signal and error datasets;
 this.signal_DSID = H5D.create (this.sqw_file_ID, this.signal_DSName, this.signal_DT, this.signal_Space,this.signal_DSProperties);
 
 write_attributes_list(this.signal_DSID,this.dataset_description_fields,this);

