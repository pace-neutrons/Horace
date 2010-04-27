function data=read_fields_list_attr(group_ID,field_names,indata)
% function reads the list of datasets from hdf5 loation  defined by group_ID
% Because of HDF5-matlab bug, the function has to be used to read data written by
% write_attrib_list  and write_fields_list_attr  functions only
%
% Inputs: 
% group_ID    -- hdf5 dataset or group location;
% field_names -- list of the entries to read;
% indata      -- the structure to add the data to;
%                may be absent
%
% Output:
% data        -- the structure with data read from the file
%
%             Key-words are used to incode unsupported data formats 
%             These key-words can not be present in the fiedls_names list:
% EMPTY_  and FILLER_

%
% V1: AB on 20/03/2010
%
%
% $Revision$ ($Date$)
%

if nargin==2 || isempty(indata)
    data=struct();
else
    data=indata;    
end

for i=1:numel(field_names)
    data.(field_names{i}) = [];
end


for i=1:numel(field_names)
    empty_attribute=false;
    try
        attr     = H5A.open(group_ID, field_names{i}, 'H5P_DEFAULT' );
    catch  % if the attribute is empty
        try
           attr     = H5A.open(group_ID,['EMPTY_',field_names{i}],'H5P_DEFAULT');
           empty_attribute=true;
        catch ERR
            error('HORACE:hdf_tools','the attribute named %s is not in the dataset,\n Error: %s',field_names{i},ERR.message);
        end
    end
    type     = H5A.get_type(attr);
    
    space     = H5A.get_space(attr);
    rank      = H5S.get_simple_extent_dims(space) ;
    type_name = H5T.get_class(type);
    if empty_attribute
       if type_name==3
            data.(field_names{i})='';                               
       else
            data.(field_names{i})=[];                    
       end
    elseif rank == 2||(type_name==3&&rank==1) % the array can be the representation of a cellarray (hdf bug)
        rez  = H5A.read(attr, type);                
        try    % it is cellarray if the attribute below exists
            attr_f = H5A.open(group_ID, ['FILLER_',field_names{i}], 'H5P_DEFAULT' );
            type_f = H5A.get_type(attr_f);
            filler = H5A.read(attr_f, type_f);
            
            rez = transform_array2cells(rez,filler,type_name);
            H5T.close(type_f);
            H5A.close(attr_f);      
        catch % not a cellarray, read as usual
        end
       data.(field_names{i})=rez;             
    else
       rez  = H5A.read(attr, type);        
       data.(field_names{i})=rez';     
    end
    
   
    H5S.close(space);
    H5T.close(type);
    H5A.close(attr);
end

function cellarray=transform_array2cells(rdata,filler,type_name)
% function constructs selarray from array rdata, written to the hdf file
% instead of variable length array to avoid hdf5-matlab bug;
dims      = size(rdata);
minDim    = dims(2);

rdata     = rdata';

cellarray = cell(1,minDim);

for i=1:minDim;
    not_filler = (rdata(i,:)~=filler);
    switch(type_name)
        case 3 % it is strings
            strl = char(rdata(i,not_filler));
            cellarray{i}=strl;            
        otherwise
            cellarray{i}=rdata(i,not_filler);
    end
    
end

