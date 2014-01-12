function save_nxspe_internal(this,filename,efix,psi)
% internal function to save loader's data in nxspe format
% inputs:
% filename -- the name of the file to write data to. Should not exist
% efix     -- incident energy for direct or indirect instrument. Only
%             direct is currently supported througn NEXUS instrument
% Optional variables:
% psi      -- the rotation angle of crystal. will be NaN if absent
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
datem=[datestr(now,31),'+00:00'];
datem(11)='T';
file_attr=struct('NeXus_version','4.3.0 ','file_name',...
    fullfile(filename),'HDF5_Version',...
    sprintf('%d.%d.%d',v1,v2,v3),'file_time',datem); % time example: 2011-06-23T09:12:44+00:00

if ~exist('emode','var')
    if isfield(this,'emode')
        emode = this.emode;
    else
        emode = 1;
    end
end
if emode<0 || emode>2
    error('A_LOADER:saveNXSPE','attempt to save with unsupported emode %d; emode has to be from 0 to 2',emode);
end
%-------------------------------------------------------------------------
% Start wriging file
%-------------------------------------------------------------------------
fcpl = H5P.create('H5P_FILE_CREATE');
fapl = H5P.create('H5P_FILE_ACCESS');
fid = H5F.create(filename,'H5F_ACC_TRUNC',fcpl,fapl);
write_attr_group(fid,file_attr);
group_name = mfilename('class');

group_id = H5G.create(fid,group_name,1000);
write_attr_group(group_id,struct('NX_class','NXentry'));
%-------------------------------------------------------------------------
% write nxspe dataset definition
if isfield(this,'nxspe_version') && isempty(this.par_file_name)
    version = this.nxspe_version;
else
    version = '1.2';
end

write_string_sign(group_id,'definition','NXSPE','version',version);
[~,hv] = herbert_version('-brief');
write_string_sign(group_id,'program_name','herbert','version',hv);
%-------------------------------------------------------------------------
% write nxspe info
if ~exist('psi','var')
    psi = NaN;
end
if ~exist('efix','var')
    efix = this.efix;
end
write_info(group_id,efix,psi);
%-------------------------------------------------------------------------
% write signal/error/det_inf  &etc
write_data(this,group_id);
%-------------------------------------------------------------------------
% write other data, typical for NeXus class
write_instrument(group_id,efix);
write_sample(group_id);

H5G.close(group_id);
H5P.close(fcpl);
H5P.close(fapl);
H5F.close(fid);
%%-------------------------------------------------------------------------
function write_sample(fid)
%
group_id = H5G.create(fid,'sample',10);
write_attr_group(group_id,struct('NX_class','NXsample'));
H5G.close(group_id);
%
function write_instrument(fid,efix)
%
group_id = H5G.create(fid,'instrument',10);
write_attr_group(group_id,struct('NX_class','NXinstrument'));
write_string_sign(group_id,'name','Horace','short_name','HOR');
%
group2_id = H5G.create(fid,'fermi',10);
write_attr_group(group2_id,struct('NX_class','NXfermi_chopper'));
double_id = H5T.copy('H5T_NATIVE_DOUBLE');
space_id = H5S.create('H5S_SCALAR');
% efix
dataset1_id = H5D.create(group_id,'energy',double_id,space_id,'H5P_DEFAULT');
H5D.write(dataset1_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',efix);
H5D.close(dataset1_id);
%
H5S.close(space_id);
H5T.close(double_id);
H5G.close(group2_id);
H5G.close(group_id);
%
function write_data(this,fid)
% write all nxspe data;

group_id = H5G.create(fid,'data',100);
write_attr_group(group_id,struct('NX_class','NXdata'));
double_id = H5T.copy('H5T_NATIVE_DOUBLE');


ds_id = write_double_dataset(group_id,'energy',this.en,double_id);
write_attr_group(ds_id,struct('units','meV'));
H5D.close(ds_id);
ds_id=write_double_dataset(group_id,'data',this.S,double_id);
H5D.close(ds_id);
ds_id=write_double_dataset(group_id,'error',this.ERR,double_id);
H5D.close(ds_id);

%-------------------------------------------------------------------------
det = this.det_par;
%
ds_id=write_double_dataset(group_id,'polar',det.phi,double_id);
H5D.close(ds_id);

ds_id=write_double_dataset(group_id,'azimuthal',det.azim,double_id);
H5D.close(ds_id);

ds_id=write_double_dataset(group_id,'distance',det.azim,double_id);
H5D.close(ds_id);

[polar_width,azim_width]=get_angular_width(det);
ds_id=write_double_dataset(group_id,'azimuthal_width',azim_width,double_id);
H5D.close(ds_id);
ds_id=write_double_dataset(group_id,'polar_width',polar_width,double_id);
H5D.close(ds_id);
%
H5T.close(double_id);
H5G.close(group_id);
%
function [polar_width,azim_width]=get_angular_width(det)
polar_width=det.width;
azim_width = det.height;
%
function dset_id=write_double_dataset(group_id,ds_name,dataset,double_id)

dims = size(dataset);
h5_dims = fliplr(dims);
h5_maxdims = h5_dims;
nds = numel(dataset);
if dims(1) == 1 || dims(2)==1
    space_id = H5S.create_simple(1,nds,nds);
    dset_id = H5D.create(group_id,ds_name,double_id,space_id,'H5P_DEFAULT');
else
    space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
    dset_id = H5D.create(group_id,ds_name,double_id,space_id,'H5P_DEFAULT');
end
H5D.write(dset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',dataset);
H5S.close(space_id);
%
function write_info(fid,efix,psi)
% write nxspe info describing nxspe incident energy, psi and ki/kf scaling
% state
group_id = H5G.create(fid,'NXSPE_info',100);
write_attr_group(group_id,struct('NX_class','NXcollection'));
double_id = H5T.copy('H5T_NATIVE_DOUBLE');
space_id = H5S.create('H5S_SCALAR');
% efix
dataset1_id = H5D.create(group_id,'fixed_energy',double_id,space_id,'H5P_DEFAULT');
H5D.write(dataset1_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',efix);
write_attr_group(dataset1_id,struct('units','meV'));
H5D.close(dataset1_id);
%psi
dataset2_id = H5D.create(group_id,'psi',double_id,space_id,'H5P_DEFAULT');
H5D.write(dataset2_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',psi);
write_attr_group(dataset2_id,struct('units','degrees'));
H5D.close(dataset2_id);
% ki/kf
int_id = H5T.copy('H5T_NATIVE_INT');
dataset3_id = H5D.create(group_id,'ki_over_kf_scaling',int_id,space_id,'H5P_DEFAULT');
H5D.write(dataset3_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',int32(1));
H5D.close(dataset3_id);
H5T.close(int_id);
%
H5T.close(double_id);
H5S.close(space_id);
H5G.close(group_id);
%
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
%
function write_string_sign(group_id,definition,name,attr_name,attr_cont)
% write information that indicates this file is nxspe file
type_id = H5T.copy('H5T_C_S1');
H5T.set_size(type_id, numel(name));
%type_id = H5T.create('H5T_STRING',numel(val));
space_id = H5S.create('H5S_SCALAR');
dataset_id = H5D.create(group_id,definition,type_id,space_id,'H5P_DEFAULT');
H5D.write(dataset_id,'H5ML_DEFAULT','H5S_ALL','H5S_ALL','H5P_DEFAULT',name);

write_attr_group(dataset_id,struct(attr_name,attr_cont));
H5D.close(dataset_id);
H5S.close(space_id);
H5T.close(type_id);
