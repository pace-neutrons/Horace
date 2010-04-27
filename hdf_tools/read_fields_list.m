function data=read_fields_list(group_ID,field_names,indata)
% function reads the list of datasets from hdf5 loation  defined by group_ID
% Because of HDF5 bug, the function has to be used to read data written by
% write_field_list function onlyl
%
% Inputs: 
% group_ID    -- hdf5 dataset or group location;
% field_names -- list of the entries to read;
% indata      -- the structure to add data to;
%
% Output:
% data        -- the structure with data read from the file
%
%
% V1: AB on 20/03/2010
%
%
% $Revision$ ($Date$)
%
data=indata;
for i=1:numel(field_names)
    data.(field_names{i}) = [];
end


for i=1:numel(field_names)
    try       
        new_datasetID=H5D.open(group_ID,field_names{i});
        dataset_DT=H5D.get_type(new_datasetID);
        rdata  = H5D.read (new_datasetID, dataset_DT, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');  
        try 
            % if there is attribut filler associated with the dataset, then
            % this dataset is modified to deal with matlab hdf bug. 
                attr=H5A.open(new_datasetID,'filler','H5P_DEFAULT');
                filetype = H5A.get_type (attr);                
                %rdata = H5A.read (attr, memtype); <- should be memtype
                filler = H5A.read (attr, filetype);                
                data.(field_names{i})=revert_array_datatype(rdata,filler,dataset_DT);
                H5T.close(filetype);
                H5A.close(attr);
        catch
            dims      = size(rdata);
            minDim    = min(dims);
            min_ind   = find(dims==minDim);
            if min_ind==2                      
                data.(field_names{i})=rdata';                                                  
            else
                data.(field_names{i})=rdata;                                  
            end
         end


        H5T.close(dataset_DT) 
        H5D.close(new_datasetID)
        
    catch
        try
            new_groupID=H5G.open(group_ID,field_names{i});
            new_fields = fieldnames(indata.(field_names{i}));
            rdata      = read_fields_list(new_groupID,new_fields,data.(field_names{i}));
            data.(field_names{i})= rdata;
            H5G.close(new_groupID);
        catch
        end
    end
end
function cellarray=revert_array_datatype(rdata,filler,filetype)
% function constructs selarray from array rdata, written to the hdf file
% instead of variable length array to avoid hdf5 bug;
dims      = size(rdata);
minDim    = min(dims);
min_ind   = find(dims==minDim);
if min_ind==1
    rdata=rdata';
end
cellarray = cell(1,minDim);
type_name = H5T.get_class(filetype);
for i=1:minDim;
    not_filler = (rdata(:,i)~=filler);
    switch(type_name)
        case 3 % it is strings
            strl = char(rdata(not_filler,i));
            cellarray{i}=strl';            
        otherwise
            cellarray{i}=rdata(not_filler,i);
    end
    
end


