function this=open_detectors_header(this,location_ID)
% function opens the dataset with detectors values
% for future IO operations;
% it also reads filename and filepath of the detector file into the memory
% for fast detector's data comparison;
%
% $Revision$ ($Date$)
%
this.detectors_DT =build_detectors_datatype(this);
avail = H5Z.filter_avail('H5Z_FILTER_DEFLATE');
if ~avail
    error ('HORACE:hdf_tools','open_detectors_header:->gzip filter not available.');
end

try
    
    this.detectors_DSID=H5D.open(location_ID,this.detectors_DSName);
    % open the dataset's dataspace
    this.detectors_Space  = H5D.get_space(this.detectors_DSID);

    [rank, dims] = H5S.get_simple_extent_dims (this.detectors_Space);
    this.n_detectors=fliplr(dims); % dimensions of dataset in the file are 
                                   % in fact flipped in relations to Matlab
    this.detectors_DSProperties = H5D.get_create_plist(this.detectors_DSID);
catch Err
    error('HORACE:hdf_tools','can not open detectors dataset, Err: %s',Err.message);
end 
% read filename and filetype
fields = this.detector_basic_fields;
data=read_fields_list_attr(this.detectors_DSID,fields );
for i=1:numel(fields )
    this.(fields {i})=data.(fields{i});
end


