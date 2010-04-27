function write_fields_list(file_ID,Group_Name,fields_list,data_structure)
% function writes selected fields of the structure data_structure 
% into peviously opened hdf file under global group name preserving the 
% structure of the data in the data_structure, namely, each field in the
% structure would correspond to a folder in hdf file. 
%
% Because of HDF5 bug, the function has to be used to wrtie data to
% interpret by read_field_list function only
%
%usage:
%    write_fields_list(file_ID,Group_Name,fields_list,data_structure)
%
% file_ID  --  the ID of the the opened HDF5 file (resulting from
%              H5F.open() of H5f.create operation)
% Group_Name - common name of the complex dataset which corresponds to the
%              data_structure we are writting
% fields_list- the list of the names of fields to be written to the file
%              All these fields have to be present in the data_structure
%              or error will be thrown. 
% data_structure -- the structure which keeps all data to be written to the
%                   HDF5 file
%
%
% V1: AB on 1/03/2010
%
% $Revision$ ($Date$)
%
n_fields = numel(fields_list);
%if Group_Name(1)~='/'
%    Group_Name=['/',Group_Name];
%end
if dataset_exist(file_ID,Group_Name)
    groupID=H5G.open(file_ID, Group_Name);        
else
    try
        groupID=H5G.create(file_ID, Group_Name, 1000);
        % errors should be clearned here
    catch Err
        message=['write_fields_list=> can not either open or create the group ',Group_Name,' Error: ',Err.message];
        error('HORACE:hdf_tools',message);
    end
end
for i=1:n_fields
    if ~isfield(data_structure,fields_list{i})
        error('HORACE:hdf_tools',['write_fields_list => field: ',fields_list{i},' requested but is not present in the input sqw data']);
    end
    write_fields_recursively(groupID,fields_list{i},data_structure);
    
end
H5G.close(groupID);



function write_fields_recursively(groupID,fieldName,struct)
% write fields recursively different datasets depending on the type of the
% field in the structure. 
DATASET = fieldName;

DATA   = struct.(fieldName);
% identify the sizes of the dataset
dims   = size(DATA);
rank   = size(dims,2);
% modify the Matlab dataset dimensions in accordence to C-rules. 
if min(dims)==1
   rank = rank-1;
   dims = max(dims);
end
if sum(dims)==0
% just return untill we can not create empty datasets;    
  return  
%   groupID=H5G.create(groupID, DATASET,0);    
%   H5G.close(groupID);  
%
%      type = hdf_type(DATA);
%      space= H5S.create('H5S_NULL');
%      dset = H5D.create (groupID, DATASET, type, space, 'H5P_DEFAULT');
%      H5D.close(dset)
%      H5S.close(space)
%    return
end

 % go recursively
if isstruct(DATA)
    fieldNames  = fieldnames(DATA);
    % place a structure data into subfolder;
    groupID = H5G.create(groupID, DATASET, 1000);        
    for i=1:numel(fieldNames)
        write_fields_recursively(groupID,fieldNames{i},DATA);
    end
    H5G.close(groupID); 
    return
end

% if the dataset with this name exist, we will just owerwrite it
% assiming that it has the same data type as written before
error_rewriting=false;
try 
    dset = H5D.open(groupID, DATASET);
    
    if iscell(DATA)
        rewrite_cell_array(dset,DATA);
    else
        % let's check if it is sufficient space allocated for dataset 
        space= H5D.get_space (dset);
        [rankf,dimsf,max_dimsf]=H5S.get_simple_extent_dims(space);
        if rankf~=0
            if rankf>1
                dimsf   = fliplr(dimsf);
                max_dimsf=fliplr(max_dimsf);
            end
            if rankf~=rank
                error_rewriting=true;            
                error('HORACE:hdf_tools','attempt to owerwrite dataset %s failed, as its new rank different from the intial one',fieldName);            
            end
            if any(dims>max_dimsf)
                error_rewriting=true;            
                error('HORACE:hdf_tools','attempt to owerwrite dataset %s failed, as its size bigger then the initially allocated size',fieldName);                       
            end
            if any(dims~=dimsf)
                if rank>1
                    dims = filplr(dims);
                end
                H5D.set_extent(dset,dims) 
            end 
           type = H5D.get_type(dset);             
        else
           if ischar(DATA)
              sdim = numel(DATA);
              type = H5T.copy ('H5T_C_S1');
              H5T.set_size (type,sdim);
           else
              type = H5D.get_type(dset);             
           end
        end
       
        try 
            % mind '??? at data!!! dataset obtained from the file is mirror of
            % Matlab dataset
            H5D.write (dset, type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT',DATA);            
        catch Err
            error_rewriting=true;
            error('HORACE:hdf_tools','attempt to owerwrite dataset %s failed, ERR: %s',fieldName,Err.message);
        end
        H5T.close(type)

        H5D.close(dset)
    end

    return    
catch Err % create new dataset as openining was not sucsessfull
    if error_rewriting
        rethrow(Err);
    end
end

% now we analyse the data and try to create a dataset, which corresponds to
% data;
if numel(DATA)==1
    type = hdf_type(DATA);     
    space= H5S.create('H5S_SCALAR');     
    dset = H5D.create (groupID, DATASET, type, space, 'H5P_DEFAULT');
    H5D.write (dset, type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT',DATA);    
elseif iscell(DATA) 
% *** cells of cells are not supported and cell array are causing other
%     problems;
    if ischar(DATA{1})&&numel(DATA)==1
    % this is a string; one string works fine        
        % *** >  this type is the memory type. A file type should be redefined later if needed;
        type = H5T.copy ('H5T_C_S1');
        H5T.set_size (type, 'H5T_VARIABLE');
    else % *** > here we have problems
       write_cell_array(groupID,DATASET,DATA);
       %type  = H5T.vlen_create (hdf_type(DATA{1}));
       return;
    end
    space = H5S.create_simple (rank,fliplr(dims), []);    
    dset  = H5D.create (groupID, DATASET, type, space, 'H5P_DEFAULT');           
    
    % Create the dataset and write the variable-length data to it.    
    %   dset  = H5D.create (groupID, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.write (dset, type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', DATA);       
   
    
    H5T.close(type)    
elseif ischar(DATA)
    type = H5T.copy ('H5T_C_S1');
    
    if size(dims)==1
            sdim = numel(DATA);
            space = H5S.create('H5S_SCALAR');                
            H5T.set_size (type,sdim);        
    else
        % *** > this branch have never been tested
        %sdim   = dims(2);
            dims(2)= 1;
            space = H5S.create_simple (rank,fliplr(dims),[]);        
            H5T.set_size (type,'H5T_VARIABLE');
   end
     dset  = H5D.create (groupID, DATASET, type, space, 'H5P_DEFAULT');
     H5D.write (dset, type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', DATA);    

    H5T.close(type)       
else  % array of some kind 
% *** only doubles were tested    
   type = hdf_type(DATA);    
   
   space = H5S.create_simple (rank,fliplr(dims),[]);
   dset  = H5D.create (groupID, DATASET, type, space, 'H5P_DEFAULT');
 
   H5D.write (dset, type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', DATA);
    
end
% handles closed in the way opposite to them being opened ?
H5D.close(dset)
H5S.close(space)
%-------------------------------------------------------------------------
function  [str_len,dims,rank]=HDF5_char_array_dims(array)
% the dimensions of Matlab array of characters differ drastically from
% other arrays; This function defines such dimensions
% 
if size(size(array)) ~= 2 
    error('HORACE:hdf_tools','HDF5_char_array_dims -> works with 2-dimension arrays of symbols only')
end
str_len=size(array,1);
rank=1;
dims=size(array,2);
        

function    write_cell_array(groupID,DATASET,DATA)
% usage:
% write_cell_array(groupID,DATASET,DATA)
%
% function creates dataset with name DATASET, creates array to accomodate
% cellarray DATA and writes this array into the dataset together with the
% attribute, which informs the read procedure that this is actually a cell
% array 
   [array,filler]=transform_cells2array(DATA);
    clear_type=false;
    
    if ischar(array)
        type = H5T.copy ('H5T_C_S1');        
        [str_length,dims,rank]=HDF5_char_array_dims(array);
        H5T.set_size (type,str_length);      
        clear_type=true;
    else
        type = hdf_type(array);    
        dims = size(array);
        rank = size(dims,2);        
    end
     
   
   space = H5S.create_simple (rank,fliplr(dims),[]);
   dset  = H5D.create (groupID, DATASET, type, space, 'H5P_DEFAULT');

   %Dwrite( dataset_id, hid_t mem_type_id, hid_t mem_space_id, hid_t file_space_id, hid_t xfer_plist_id, const void * buf  )    
   H5D.write (dset, type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', array);
   
   % create atribute which will identiry the variable lentgh dataset in the
   % array
   if clear_type
       H5T.close(type);
   end
   H5S.close(space);
   try 
       attr=H5A.open(dset,'filler',H5P_DEFAULT);
       space=H5A.get_space(attr);
   catch
       space = H5S.create('H5S_SCALAR');
       attr=H5A.create(dset,'filler','H5T_NATIVE_DOUBLE',space,'H5P_DEFAULT');
   end
   H5A.write(attr, 'H5T_NATIVE_DOUBLE', filler);
   H5S.close(space);
   H5A.close(attr);
   H5D.close(dset);
%-------------------------------------------------------------------------   
function    rewrite_cell_array(dset,DATA)
   [array,filler]=transform_cells2array(DATA);

   type = hdf_type(array);    
   if strcmp(type,'H5T_NATIVE_CHAR')
     [str_length,dims,rank]=HDF5_char_array_dims(array);
   else
     dims = size(array);
     rank = size(dims,2);       
   end
   
   space = H5D.get_space (dset);
   [rank1, dims1]= H5S.get_simple_extent_dims (space);
   dims1=fliplr(dims1);

   if any(abs(dims-dims1)>1.e-3)|| abs(rank-rank1)>1.e-3
       error('HORACE:hdf_tools','rewrite_cell_array-> attempt to owerwrite existing dataset but the dimensions do not match')
   end
   type = H5D.get_type(dset);
    
   H5D.write (dset, type, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', array);
   
   % create atribute which will identiry the variable lentgh dataset in the
   % array
   H5S.close(space);
   H5T.close(type);
   try 
       attr=H5A.open(dset,'filler','H5P_DEFAULT');
       space=H5A.get_space(attr);
   catch Err
     error('HORACE:hdf_tools','rewrite_cell_array-> can not open cellarray attribure, Err: %s',Err.message)       ;
   end
   H5A.write(attr, 'H5T_NATIVE_DOUBLE', filler);
   H5S.close(space);
   H5A.close(attr);



function [array,filler]=transform_cells2array(cellarray)
% function creates array which corresponds to cellarray but is of defined 
% length to  accomodate all variable length data in the cellarray; 
% usage:
% [array,filler]=transform_cells2array(cellarray)
%
% if the length of data in cellarray exceeds the defined length of the
% array, the data in array are tunkated;
% if the length of the data less then allocated space, the rest of space in
% the array is padded by filler;
% 
if ~iscell(cellarray)
    error('HORACE:hdf_tools','transform_cells2array -> the argument of the fucntion has to be cellarray')
end
%
if isa(cellarray{1},'char')
    filler=0;
    array_length=get(config,'hdf_string_max_length');
    array=char(zeros(array_length,numel(cellarray)));
    array(:,:)=filler;
else
    array_length=get(config,'hdf_array_max_length');    
    minVal = min(min([cellarray{:}]));
    filler= minVal-1;
    if filler==0,  filler=-1;
    end
    if filler==minVal
        warning('HORACE:hdf_tools',' can not choose proper filler for double array; the arrays will be truncated by value %f',filler);
    end
    
    array=zeros(array_length,numel(cellarray));    
    array(:,:)=filler;
    
end
for i=1:numel(cellarray)
   str = cellarray{i};    
   d_length = numel(str);
  
   if d_length<array_length
      array(1:d_length,i)=str(1:d_length);
   else
      array(:,i)=str(1:array_length);
   end
end

