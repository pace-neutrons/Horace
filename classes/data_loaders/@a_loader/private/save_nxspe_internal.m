function save_nxspe_internal(this,filename,efix,psi)
% internal function to save loaders data in nxspe format
%
% $Author: Alex Buts; 05/01/2014
%
%
% $Revision$ ($Date$)
%



if exist(filename,'file')
    error('A_LOADER:saveNXSPE','File %s already exist',filename);
end
[v1,v2,v3]= H5.get_libversion();
file_attr=struct('NeXus_version','4.3.0 ','file_name',...
    fullfile(filename),'HDF5_Version',...
    sprintf('%d.%d.%d',v1,v2,v3),'file_time',datestr(now,31)); % time example: 2011-06-23T09:12:44+00:00



fcpl = H5P.create('H5P_FILE_CREATE');
fapl = H5P.create('H5P_FILE_ACCESS');
fid = H5F.create(filename,'H5F_ACC_TRUNC',fcpl,fapl);
write_attr_group(fid,file_attr);
group_name = mfilename('class');

group_id = H5G.create(fid,group_name,1000);
write_attr_group(group_id,struct('NX_class','NXentry'));
% write nxspe dataset definition
write_nxspe_sign(group_id)


write_info(this,efix,psi);
write_data(this);
write_instrument(efix);
write_sample();

H5G.close(group_id);
H5P.close(fcpl);
H5P.close(fapl);
H5F.close(fid);


function write_nxspe_sign(group_id)
type_id = H5T.copy('H5T_C_S1');
H5T.set_size(type_id, numel('NXSPE'));
%type_id = H5T.create('H5T_STRING',numel(val));
space_id = H5S.create('H5S_SCALAR');
dataset_id = H5D.create(group_id,'definition',type_id,space_id,'H5P_DEFAULT');
H5D.write(dataset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT','NXSPE');

write_attr_group(dataset_id,struct('version','1.2'));
H5D.close(dataset_id);
H5S.close(space_id);
H5T.close(type_id);


function write_info(this,efix,psi)
return
function write_data(this)
return
function write_instrument(efix)
return
function write_sample()
return

function write_attr_group(group_id,data)


attr_names = fieldnames(data);
for i=1:numel(attr_names)
    
    an = attr_names{i};
    val = data.(an);
    
    if isstring(val)
        type_id = H5T.copy('H5T_C_S1');
        H5T.set_size(type_id, numel(val));
        %type_id = H5T.create('H5T_STRING',numel(val));
        space_id = H5S.create('H5S_SCALAR');
        %loc_id, name, type_id, space_id, acpl_id
        attr_id = H5A.create(group_id,an,type_id,space_id,'H5P_DEFAULT');
        H5A.write(attr_id,'H5ML_DEFAULT',val);
        
        H5A.close(attr_id);
        H5S.close(space_id);
        H5T.close(type_id);
    end
    
end

%error('NOT_IMPLEMENTED:save_nxspe')
