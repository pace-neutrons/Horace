function [ds_names,is_empty,this]=list_spe_datasets(this)
% function return the structure with the parameters spe datasets, located under specified
% group name. the group name is defined by the field:
% this.HeaderDSName
% and has to be located at root level of hdf spe file

% side effects:
% if number of the group in the file is bigger then current nInstance num,
% the nInstance increases to the number in the group. 
%
% $Revision$ ($Date$)
%

    fileName = full_file_name(this);
    fileinfo = hdf5info(fileName,'ReadAttributes',true);

    % group name we are looking for is the name specified in class +
    % possible slash and optional name. We have to accound for all possible
    % variations of the name 

    [requested_group_name,add_length] = hdf_group_name(this.HeaderDSName);
    requested_group_name=requested_group_name{1};
    
    % function returns all groups 
    groups = fileinfo.GroupHierarchy;
    if isempty(groups.Groups)
        error('HORACE:hdf_tools','spe_header:retrieving data fiedls-> no groups has been found in the hdf file %s, it is not correct spe header',this.filename);            
    end
    %find the group, which corresponds to spe header and is defined in the
    %class header; This group has to be under specified depth of the hdf
    %file-system. 
    fields = groups.Groups;
    found  = -1;
    length = numel(requested_group_name);
    for i=1:numel(fields)
        if strncmp(fields(i).Name,requested_group_name,length)
            exactGroup=fields(i);
            found =i;
            break
        end
    end
    if found<0
        error('HORACE:hdf_tools','spe_header:retrieving data fiedls-> no groups has been found in the hdf file %s, it is not correct spe header',this.filename);                    
    end
    % let's identify the requested group number in the file
    group_name_length = numel(this.HeaderDSName)+add_length+2;
    if group_name_length > numel(exactGroup.Name) % if the name without the number, the instance of this class is 0
         this.nInstance=0;       
    else % if the group name consist of the name and the number, parce it
         nn = exactGroup.Name(group_name_length:numel(exactGroup.Name));
         this.nInstance=str2double(nn);        
    end
    
    % try to keep any future  hdf group name unique 
    global nInstances;       
    if this.nInstance>nInstances
            nInstances = this.nInstance;
    end
    % and now, when the proper group is identified, let's obtain the list of spe
    % datasets;
    %ds_names = exactGroup.Datasets;
    ds = exactGroup.Attributes;
   
    if isempty(ds)
        ds_names={};
    else
        ds_names={ds.Name};
       % remove service fields, which are used to deal with hdf bug    
        not_fillers =cellfun('isempty',regexp(ds_names,'FILLER_','once'));
        ds_names=ds_names(not_fillers); 
        is_empty    =~cellfun('isempty',regexp(ds_names,'EMPTY_','once'));
        ds_names    = cellfun(@strip_empty,ds_names,'UniformOutput',false);
    end
%
%
    function empty_stripped=strip_empty(field)
        empty_stripped=regexprep(field,'EMPTY_','','once');
