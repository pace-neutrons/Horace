function [sqw_data,this]=read_spe_header(this,file_ID,varargin)
% function reads the auxiliary fields existing in swq_data and defined by the 
% field this.field_names into recursive data sructure under the header
% this.HeaderDSName
%
% varargin{1} -- if present should be the structure, with fields we want to read;
%                the operation will fail if these fields are not present in the file
%
% $Revision$ ($Date$)
%
if nargin > 2
    if ~isstruct(varargin{1})
        error('HORACE:hdf_tools','read_spe_header-> the thidr parameter, if present has to be a data structure');        
    end
    sqw_data = varargin{1};
    % get the fields of the structure; if some fields are not present in
    % the file, read will fail
    fields   = fieldnames(sqw_data);
else    
    sqw_data = struct();
% get the list of spe datasets present in the file   
    fields   = data_fields(this,'-brief');    
end
% exclude fields which can not belong to header
fields_not_here =~ismember(fields,this.non_spe_field_names); 
fields = fields(fields_not_here);

globalGroupName = hdf_group_name(this.HeaderDSName);
group_ID        = H5G.open(file_ID,globalGroupName{1});

% read this part of the structure;
sqw_data=read_fields_list_attr(group_ID,fields,sqw_data); 

% copy fields which have to be present in the class from the output
% structure to the class fields;
fields_here    = ismember(fields,this.this_field_names);
header_fields  = fields(fields_here);
for i=1:numel(header_fields)
    this.(header_fields{i})=sqw_data.(header_fields{i});
end
%
H5G.close(group_ID);
