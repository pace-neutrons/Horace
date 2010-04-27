function this=open_signal_dataset(this)
% internal method for one_sqw class
% function opens signal error and pixel datasets which should be present in
% an existing and opened hdf5 file
%
%
% $Revision$ ($Date$)
%
% file has to be opened
file_ID  = this.sqw_file_ID;
%

% open the dataset which has to be present in the file;
this.signal_DSID=H5D.open(file_ID,this.signal_DSName);

% open the dataset's dataspace
this.signal_Space  = H5D.get_space(this.signal_DSID);

% the function knows the signal datatype layout and structure
%this.signal_DT=build_signal_datatype();
this.signal_DT=H5D.get_type (this.signal_DSID);


[rank, dims,max_dims] = H5S.get_simple_extent_dims (this.signal_Space);
this.signal_dims=fliplr(dims); % dimensions of dataset in the file are 
                               % in fact flipped in relations to Matlab
                                                             
%dims = fliplr(dims);
this.signal_DSProperties = H5D.get_create_plist(this.signal_DSID);

fields = this.dataset_description_fields; % for clarity
data=read_fields_list_attr(this.signal_DSID,fields);

for i=1:numel(fields)
    this.(fields{i})=data.(fields{i});
end
