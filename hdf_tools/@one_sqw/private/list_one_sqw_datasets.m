function ds_names=list_one_sqw_datasets(this)
% function return the structure with the names of datasets, located
% at the  at root level of hdf one_spe file

%
% $Revision$ ($Date$)
%

    fileName = full_file_name(this);
    fileinfo = hdf5info(fileName,'ReadAttributes',true);

    % function returns all groups 
    groups = fileinfo.GroupHierarchy;
    if isempty(groups.Groups)
        error('HORACE:hdf_tools','spe_header:retrieving data fiedls-> no groups has been found in the hdf file %s, it is not correct spe header',this.filename);            
    end
    %find the group, which corresponds to spe header and is defined in the
    %class header; This group has to be under specified depth of the hdf
    %file-system. 
    ds = groups.Datasets;
    
    if isempty(ds)
        ds_names={};
    else
        ds_names={ds.Name};
     end
    
