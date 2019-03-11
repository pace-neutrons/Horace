function [fid,group_id,file_h,sqw_version] = open_or_create_nxsqw_head(f_name)
% function creates hdf5 file containing nxsqw file header
%
% returns hdf file identifier and hdf group for data access and later
% closing
%
%
% $Revision$ ($Date$)
%


% nxsqw format version. First nxsqw version is 4.0, previous versions are
% binary sqw versions.
sqw_version = '4.0';
data_format = 'NXSQW';

[~,short_fn] = fileparts(f_name);
group_name = ['sqw_',short_fn];

if exist(f_name,'file') == 2
    [root_nx_path,sqw_version,data_structure] = find_root_nexus_dir(f_name,data_format);
    fid =  H5F.open(f_name,'H5F_ACC_RDWR','H5P_DEFAULT');
    if fid<=0
        error('NXSQW:io_error',...
            'Can not open nxsqw file %s with RW access',...
            f_name);
    end
    file_h = [];
    if H5L.exists(fid,group_name,'H5P_DEFAULT')
        group_id = H5G.open(fid,root_nx_path);
    else
        group_id=create_root_group(fid,group_name,data_format);
    end
else
    [v1,v2,v3]= H5.get_libversion();
    datem=[datestr(now,31),'+00:00'];
    datem(11)='T';
    file_attr=struct('NeXus_version','4.3.0 ','file_name',...
        fullfile(f_name),'HDF5_Version',...
        sprintf('%d.%d.%d',v1,v2,v3),'file_time',datem); % time example: 2011-06-23T09:12:44+00:00
    
    
    %-------------------------------------------------------------------------
    % Start writing file
    %-------------------------------------------------------------------------
    fid =  H5F.create(f_name,'H5F_ACC_TRUNC',[],[]);
    %
    % make this file look like real nexus
    if matlab_version_num()<=7.07
        %pNew->iVID=H5Gopen(pNew->iFID,"/");
        file_h = fid;
        fid = H5G.open(fid,'/');
    else
        file_h = [];
    end
    write_attr_group(fid,file_attr);
    
    group_id=create_root_group(fid,group_name,data_format,sqw_version);
end

function group_id=create_root_group(group_location,group_name,data_format,format_version)


group_id = H5G.create(group_location,group_name,1000);
% nexus data id
write_attr_group(group_id,struct('NX_class','NXentry'));
%-------------------------------------------------------------------------
% write sqw dataset definition

write_string_sign(group_id,'definition',data_format,'version',format_version);
[~,hv] = horace_version('-brief');
write_string_sign(group_id,'program_name','horace','version',hv);
