function this=create_pix_dataset(this)
% function creates the datasets for signal and pixels
% data in an hdf file. If the file has been opened, 
% the function creates all correspondent datasets
% the format of the datasets is has to be defined earlier
%
% $Revision$ ($Date$)
%
if this.file_is_opened
    file_ID = this.sqw_file_ID;
    file_opened_initially=true;
else
    file_ID = open_or_create(this.file_name);    
    file_opened_initially=false;    
end

%
% $Revision$ ($Date$)
%
avail = H5Z.filter_avail('H5Z_FILTER_DEFLATE');
if ~avail
    error ('HORACE:hdf_tools','define_sqw_datasets:->gzip filter not available.');
end
%
% Pixel datasets
%
% pixel dataset has to agree with the write command as we can put different
% values there. 
this=build_pixel_datatype(this);
 
 H5S_UNLIMITED = H5ML.get_constant_value('H5S_UNLIMITED');
 dims    = this.pixel_dims(2);
 rank    = 1;
 maxdims = H5S_UNLIMITED;
 this.pixel_Space = H5S.create_simple(rank,fliplr(dims),fliplr(maxdims));

 % pixel dataset properties
 this.pixel_DSProperties = H5P.create('H5P_DATASET_CREATE');
% H5P.set_fill_value(this.pixel_DSProperties, this.pixel_DT, 0)
 
 chunk = this.pixel_DS_chunk;
 H5P.set_chunk(this.pixel_DSProperties, fliplr(chunk));
 H5P.set_deflate(this.pixel_DSProperties, this.pixel_DS_compression);



% pixel dataset;
 this.pixel_DSID=H5D.create (file_ID, this.pixel_DSName, this.pixel_DT, this.pixel_Space,this.pixel_DSProperties);
 
if ~file_opened_initially
    H5F.close(file_ID);
end

