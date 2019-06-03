function [dataset_info,ds_group_path] = find_dataset_info(Groups,the_group_name,ds_short_name)
% fucntion searches through hdf5 file structure for specified group,
% and/or dataset
% 
%>>[dataset_info,ds_group_path] = find_dataset_info(hdf5_file,folder_name,data_file_name,)
%>>[dataset_info,ds_group_path] = find_dataset_info(hdf_file_structure,folder_name,data_file_name)
%>>[dataset_info,ds_group_path] = find_dataset_info(branch_of_hdf_file_structure,folder_name,data_file_name)

%Inputs:
% hdf_file_structure    -- the structure of the hdf5 file, obtained by
%                          function hdf5info or
% hdf5_file             -- the name of hdf5 file or
% 
% branch_of_hdf_file_structure=dataset_info
%                        -- part of the srtucture found by previous search
%                           for group (with empty data_file_name)
%
% folder_name           -- if not empty, the short name of the group(folder), the
%                          dataset have to belong to. If it does not exist,
%                          the search goes for first dataset.
% 
% data_file_name        -- the short name of the dataset to look for (if
%                          empty, then search is performed by the
%                          group(folder) name only.
%
% The search occurs recursively and ends on the first folder(group)
% and dataset which have proper folder_name and data_file_name.
%
%Outputs:
%dataset_info   -- the srcucture which describes the hdf5 folder with
%                  requested name
%data_file_name -- full name to the dataset requseted can be used in
%                  hdf5read/hdf5write to access the dataset
%
% folder_name and data_file_name are empty if nothing was found
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
%
%
%--> clear search request
if ~isempty(the_group_name)
    if the_group_name(1)=='/'
        the_group_name = the_group_name(2:end);
    end   
    if the_group_name(end)=='/'
        the_group_name = the_group_name(1:end-1);
    end       
end
if ~isempty(ds_short_name)
    if ds_short_name(1)=='/'
        ds_short_name = ds_short_name(2:end);
    end   
    if ds_short_name(end)=='/'
        ds_short_name = ds_short_name(1:end-1);
    end       
end
%--> transfrom input into standard form
if isstruct(Groups) %got some file srtucture;
    if isfield(Groups,'LibVersion') && isfield(Groups,'GroupHierarchy')% it is hdf5file structure
        gh = Groups.GroupHierarchy;     
    else
        if ~isfield(Groups,'Name')
            error('FIND_DATASET_INFO:invalid_argument',' input structhre is not correct hdf file info\n');
        end
        gh = Groups;   
    end
elseif ischar(Groups) % may be it is a file
    [path,filename,ext]=fileparts(Groups);
    [ok,mess,file] = check_file_exist(fullfile(path,[filename ext]),ext);
    if ~ok
        error('FIND_DATASET_INFO:check_file_exist',mess);
    end
    if ~H5F.is_hdf5(file)
        error('FIND_DATASET_INFO:invalid_file',' file %s is not recognized as hdf5 file',file);
    end
    fileinfo = hdf5info(file);
    gh = fileinfo.GroupHierarchy;
else
    error('FIND_DATASET_INFO:invalid_argument',' input argument is nether hdf file info not a file name\');
end
%
%%--> search itself
if gh.Name(end) ~= '/'            
   full_parh = [gh.Name,'/',the_group_name];
else
   full_parh = [gh.Name,the_group_name];              
end

[dataset_info,ds_group_path] = look_in_current_folder(gh,full_parh,the_group_name,ds_short_name);


%-----------------------------------------------------
function [dataset_info,ds_full_name]=look_in_current_folder(dataset_info,this_folder_name,shrt_group_name,ds_short_name)

% the search folder name is empty or
% the name of search folder coinside with current name     
if isempty(shrt_group_name) || strcmp(dataset_info.Name,this_folder_name)     
     if isempty(ds_short_name)
         ds_full_name = this_folder_name;
         return % all found
     else
       [dataset_info_tmp,ds_found_full_name] = look_in_datasets(dataset_info,this_folder_name,ds_short_name);
       if ~isempty(ds_found_full_name)
          dataset_info=dataset_info_tmp;
          ds_full_name=ds_found_full_name;                        
          return;
       end
       
       if isempty(shrt_group_name)
          for i=1:numel(dataset_info.Groups)
             [dataset_info_tmp,ds_found_full_name]= ...
             look_in_current_folder(dataset_info.Groups(i),dataset_info.Groups(i).Name,'',ds_short_name);
             if ~isempty(ds_found_full_name)
                  dataset_info=dataset_info_tmp;
                  ds_full_name=ds_found_full_name;                  
                  return;
             end
          end             
      end        
     end


else
 
   if dataset_info.Name(end) == '/'            
         ds_full_name = [dataset_info.Name,shrt_group_name];                         
   else
         ds_full_name = [dataset_info.Name,'/',shrt_group_name];            
   end         
   
   for i=1:numel(dataset_info.Groups)
        [dataset_info_tmp,ds_found_full_name]=look_in_current_folder(dataset_info.Groups(i),ds_full_name,shrt_group_name,ds_short_name);
        if ~isempty(ds_found_full_name)
            dataset_info=dataset_info_tmp;
            ds_full_name=ds_found_full_name;
            return;
        end
   end
end
ds_full_name = '';

%
function [dataset_info,ds_full_name] = look_in_datasets(dataset_info,this_folder_name,ds_short_name)

if this_folder_name(end) == '/'            
     ds_full_name = [this_folder_name,ds_short_name];                         
else
     ds_full_name = [this_folder_name,'/',ds_short_name];            
end         

for i=1:numel(dataset_info.Datasets)
    if strcmp(dataset_info.Datasets(i).Name,ds_full_name)
        dataset_info = dataset_info.Datasets(i);
        return
    end    
end
ds_full_name ='';
   

