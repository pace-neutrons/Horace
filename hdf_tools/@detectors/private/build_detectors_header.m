function  this=build_detectors_header(this,location_ID)
% private method for detectors class
% build detector datatype, creates detectors group and opens this group for
% IO operations
%
%
% $Revision$ ($Date$)
%
 
this.detectors_DT =build_detectors_datatype(this);
avail = H5Z.filter_avail('H5Z_FILTER_DEFLATE');
if ~avail
    error ('HORACE:hdf_tools','build_detectors_header:->gzip filter not available.');
end

try
    
    this.detectors_DSID=H5D.open(location_ID,this.detectors_DSName);
    % open the dataset's dataspace
    ths.detectors_Space  = H5D.get_space (this.detectors_DSID);

    [rank, dims] = H5S.get_simple_extent_dims (this.detectors_Space);
    this.n_detectors=fliplr(dims); % dimensions of dataset in the file are 
                                  % in fact flipped in relations to Matlab
    this.detectors_DSProperties = H5D.get_create_plist(this.detectors_DSID);
   
catch
    % detectors dataset;
    % 
    %  Define dataspace 
    %
    maxdims = {'H5S_UNLIMITED'};
    this.detectors_Space=H5S.create_simple (1,this.n_detectors,maxdims);
    %
    % Define dataset properties
    %
    this.detectors_DSProperties= H5P.create('H5P_DATASET_CREATE');
    H5P.set_chunk(this.detectors_DSProperties, this.n_detectors);
    H5P.set_deflate(this.detectors_DSProperties, this.detectors_DS_compression);
    
    this.detectors_DSID = H5D.create (location_ID, this.detectors_DSName, this.detectors_DT, this.detectors_Space,this.detectors_DSProperties);
end

write_attributes_list(this.detectors_DSID,this.detector_basic_fields,this);
