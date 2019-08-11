function [fid,group_name,group_id,file_h,sqw_version] = open_or_create_nxsqw_head(f_name)
% function creates hdf5 file containing nxsqw file header or opens such
% file if the file exist
%
% returns hdf file identifier and hdf group for data access and later
% closing
%Usage: 
%>>[fid,group_name,group_id,file_h,sqw_version] =open_or_create_nxsqw_head(f_name);
%
%Where: 
% f_name -- the name of a nxsqw file
%
%Returns:
% fid    -- hdf5 id for opened hdf5 file. Should be closed by H5F.close
%           when the file is done with. (Matlab invokes destructor so needs
%           to be kept if file is used
% group_name-- the name of main nxsqw group with all nxsqw data location. 
% group_id -- hdf5 id for access to opened nxsqw group. 
%           Should be colsed by H5G.close when dealt with. 
%
% file_h  -- hdf5 file id for old hdf5 version. (some early versions of 
%            hdf5 1.6) The mounting point of all data in such files is / 
%            and this is assigned to fid in old data formats. The fid 
%            in this case should be closed by H5G.close and the fild_h
%            itself closed by H5F.close.
%
% sqw_version -- the version of nxsqw file. 
%
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%
%
%
% nxsqw format version. First nxsqw version is 4.0, previous versions are
% binary sqw versions.
sqw_version = '4.0'; % Current nxsqw version. Existing file would redefine 
                     % this to have its creation version.
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
    group_name = root_nx_path(2:end);
    file_h = []; % stub -- we do not use old Matlab abyway. 
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
