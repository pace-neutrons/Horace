function write_attributes_list(groupID,fields_list,data_structure)
% function writes list of fields from the data structure into correspondend
% attributes associated with location defined by groupID;
%
% V1: AB on 1/03/2010
%
% $Revision$ ($Date$)
%
n_fields = numel(fields_list);
for i=1:n_fields
    if ~isfield(data_structure,fields_list{i})
        error('HORACE:hdf_tools','write_attributes_list => field: %s is requested but not present in the input data structure',...
                                  fields_list{i});
    end
    write_fields(groupID,fields_list{i},data_structure);
end


function write_fields(groupID,fieldName,struct)
% write fields  into different datasets depending on the type of the
% field in the structure. 
ATTRIBUTE = fieldName;
DATA   = struct.(fieldName);

% identify the sizes of the dataset
dims   = size(DATA);
rank   = size(dims,2);
% modify the Matlab dataset dimensions in accordence to C-rules. 
if min(dims)==1
   rank = rank-1;
   dims = max(dims);
end

% usual attribure is not empty; Here we are trying to deal with empty
% attributes, which are not supported by Matlab
empty_attribute=false;
if sum(dims)==0
    % have to invent special name for an empty attribute
    empty_attribute=true;
    rank=0;
    ATTRIBUTE=['EMPTY_',ATTRIBUTE];
end
% filler intended to overcome problems with variable length datasets;
filler_attribute=false;

% the attribute can be created in the file before. To create it for writing
% again, the previous one has to be deleted;
try 
    H5A.delete(groupID,ATTRIBUTE);  
catch
    % the attribute can be initially empty but not any more. Let's try to
    % delete it 
    try 
        H5A.delete(groupID,['EMPTY_',ATTRIBUTE]);          
    catch
    end
    
end

% now we analyse the data and try to create an attribute, which corresponds to
% the data;
if ischar(DATA)
    nn   = numel(DATA);
    type = H5T.copy ('H5T_C_S1');               
    if nn==0 && empty_attribute       
        nn=1;
        DATA=char(0);       
    end    
    H5T.set_size (type,nn);             

    if rank>1
        space = H5S.create_simple (rank,fliplr(dims),[]);            
    else
        space=H5S.create('H5S_SCALAR');
    end

elseif numel(DATA)==1
    type = hdf_type(DATA);     
    space= H5S.create('H5S_SCALAR');     
elseif iscell(DATA) 
% *** cells of cells are not supported and cell array are causing other
%     problems;
    [DATA,filler]=transform_cells2array(DATA);
    filler_attribute=true;
    if ischar(DATA)
        % *** >  this type is the memory type. A file type should be redefined later if needed;
        type = H5T.copy ('H5T_C_S1');
        H5T.set_size (type, length(DATA));
        space = H5S.create_simple (rank,fliplr(dims), []);    
        
    else % *** > here we have problems
       type  = hdf_type(DATA);
       dims  = size(DATA);
       space = H5S.create_simple (2,fliplr(dims), []);    
    end  
    
    
else  % array of some kind 
% *** only doubles were tested    
   type = hdf_type(DATA);    

  if rank==0 && empty_attribute % empty dataspace -- matlab does not support mull!!! 
       space=H5S.create('H5S_SCALAR');
       DATA = realmin;
  else
       space = H5S.create_simple (rank,fliplr(dims),[]);
  end

   
end
attr = H5A.create (groupID, ATTRIBUTE, type, space, 'H5P_DEFAULT');
H5A.write (attr, type, DATA);    

% handles closed in the way opposite to them being opened ?
H5S.close(space)
if ~ischar(type)
    H5T.close(type)
end
H5A.close(attr)

%-------------------------------------------------------
if filler_attribute
    ATTR_FILLER=['FILLER_',fieldName];
    type = hdf_type(filler);     
    space= H5S.create('H5S_SCALAR');     
    try 
        attr= H5A.open_name (groupID, ATTR_FILLER);
    catch
        attr = H5A.create (groupID, ATTR_FILLER, type, space, 'H5P_DEFAULT');      
    end    
    H5A.write (attr, type, filler);    
    H5S.close(space)
    H5A.close(attr)    
end
%----------------------------------------------------
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
ml=zeros(1,numel(cellarray));
for i=1:numel(cellarray)
    ml(i)=length(cellarray{i});
end
array_length=max(ml);
if isa(cellarray{1},'char')
    filler=0;
    array=char(zeros(array_length,numel(cellarray)));
    array(:,:)=filler;
else
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
