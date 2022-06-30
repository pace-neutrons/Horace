function [root_nx_path,data_version,data_structure] = find_root_nexus_dir(hdf_fileName,nexus_application_name,test_mode)
% function identifies the path to the root folder in the input NeXus data file
% This folder can be later used as hdf path to the data, accessed using hdf5read/hdf5write functions
%
%Usage:
%>>root_folder=find_root_nexus_dir(nexus_file_name,'NXSPE')
%>>root_folder=find_root_nexus_dir(nexus_file_name,NeXus_application_name)
%             -- returns the path to a nxspe data if they are present in current NeXus file
%             -- if the data are absent, function returns empty  string
%Inputs:
% hdf_fileName           -- the name of hdf5 NeXus file
% nexus_application_name -- the name of the NeXus application (in NeXus
%                            sence), which describes specific data
%                            structure. The procedure has been tested on
%                            NXSPE data (application) though should work
%                            for any data organized as NeXus application
%
%Outputs:
%root_folder   --    The root folder is a hdf5 folder where all application's
%                    (nxspe) data are related to.
%data_version  --     the version of the NeXus application's data (may
%                      define the data format)
%data_structure --   The structure  describes the arrangement of the hdf5
%                    data folders and attribures within the file hdf5 file.
%                    This structure can be (and was) obtained by hdf5info
%                    function and returned by this procedure for
%                    efficiency (if needed, not to read it again).
%
%

if ~exist('nexus_application_name', 'var')
    nexus_application_name = 'NXSPE';
end
if nargin>2
    test_mode  = true;
else
    test_mode = false;
end
data_structure =  h5info(hdf_fileName);
groups         =  data_structure.Groups(:);

n_nx_entries=0;
nx_folders=cell(1,1);
nx_version=cell(1,1);
for i=1:numel(groups)
    % obtain the short name (the name of the last folder in a hdf hirackhy) of the attribute
    if ~isfield(groups(i),'Attributes') || isempty(groups(i).Attributes)
        error('HERBERT:isis_utilities:invalid_argument',...
            'hdf file %s is not valid NEXUS file',hdf_fileName);
    end
    [~,shortName] = fileparts(groups(i).Attributes.Name);
    % if this attribute is NX_class, look further:
    if strcmp(shortName,'NX_class')&&strcmp(groups(i).Attributes.Value,'NXentry')
        nexus_folder = groups(i);
        for j=1:numel(nexus_folder.Datasets)
            if strcmp('definition',nexus_folder.Datasets(j).Name)
                def_path = [nexus_folder.Name,'/definition'];
                definition = h5read(hdf_fileName,def_path);
                if strcmp(definition,nexus_application_name)
                    n_nx_entries=n_nx_entries+1;
                    nx_folders{n_nx_entries}= nexus_folder.Name;
                    nx_version{n_nx_entries}= ...
                        get_version(nexus_folder.Datasets(j),nexus_application_name,hdf_fileName);
                end
            end
        end
    end
end

if(n_nx_entries==0)
    root_nx_path='';
    return;
end
if(n_nx_entries>1)
    if ~test_mode
        error('HERBERT:isis_utilities:invalid_argument',...
            ' found multiple nxspe folders in file %s but this function does not currently support multiple nxspe folders',hdf_fileName)
    end
    root_nx_path = nx_folders;
    data_version    = nx_version;
else
    root_nx_path = nx_folders{1};
    data_version    = nx_version{1};
end

function ver=get_version(def_dataset,APP_NAME,filename)
% get nexust version from nexus attributes
%
for i=1:numel(def_dataset.Attributes)
    attr = def_dataset.Attributes(i);
    if strcmp(attr.Name,'version')
        ver = attr.Value;
        if iscell(ver)
            ver = regexprep(ver{1},'[\n\r\0]+','');
        end
        return;
    end
end
error('HERBERT:isis_utilities:invalid_argument',...
    'Dataset %s in file %s does not have correct version',APP_NAME,filename)
