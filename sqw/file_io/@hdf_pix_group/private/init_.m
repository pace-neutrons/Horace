function init_(obj,filename,varargin)
% initialize hdf_pixel_group within the nxspe file to perform IO operations
% with pixels group.
%Usage:
%>>obj = hdf_pixel_group(filename); open existing pixels group
%                              for IO operations. Throws if
%                              the group does not exist.
%          a writing (if any) occurs into the existing group
%          allowing to modify the contents of the pixel array.
%
%>>obj = hdf_pixel_group(filename,n_pixels,[chunk_size]);
%          creates pixel group to store specified number of
%          pixels.
% If the group does not exist, additional parameters describing
% the pixel array size have to be specified. If it does exist,
% all input parameters except fid will be ignored
%
% Inputs:
% filename -- nxnspe file name with nxsqw information
%
% n_pixels -- number of pixels to be stored in the pix dataset.
%
%
% chunk_size -- if present, specifies the chunk size of the
%               chunked hdf dataset to create. If not, default
%               class value is used
%          If the pixel dataset exists, and  its sizes are
%          different from the values, provided with this
%          command, the dataset will be recreated with new
%          parameters. Old dataset contents will be destroyed.
%

%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%



options = {'-use_mex_to_read','-use_matlab_to_read'};
[ok,mess,use_mex_to_read,use_matlab_to_read,argi]=parse_char_options(varargin,options);
if ~ok
    error('HDF_PIX_GROUP:invalid_argument',mess);
end
if use_mex_to_read && use_matlab_to_read
    error('HDF_PIX_GROUP:invalid_argument',...
        '"-use_mex_to_read" and "-use_matlab_to_read" are confliction options not to be used together');
end
%
if numel(argi) > 0 %exist('n_pixels','var')|| exist('chunk_size','var')
    pix_size_defined = true;
    n_pixels = argi{1};
else
    pix_size_defined = false;
    n_pixels = [];
end
if numel(argi)> 1%exist('chunk_size','var')
    chunk_size = argi{2};
    obj.chunk_size_ = chunk_size;
else
    chunk_size = obj.chunk_size_;
end

if ~ischar(filename)
    error('HDF_PIX_GROUP:invalid_argument',...
        ' First input of the hdf_pix_group init method should be the name of the nxspe file, containing this group');
end
if ~exist(filename,'file')==2 && ~pix_size_defined
    error('HDF_PIX_GROUP:invalid_argument',...
        ' If new nxsqw file is created, its necessary to specify the number of pixels to be stored in it');
end



if ~(use_mex_to_read || use_matlab_to_read) % use configuration to verify what to do with mex
    hc = hor_config;
    use_mex_to_read  = hc.use_mex;
end
if use_mex_to_read
    if ~(exist(filename,'file')==2) % Let's assume for now that if a file exist, it allways contain full information.
        use_mex_to_read = false;    % if it created, mex is unappropriate for reading.
        obj.use_mex_to_read_ = false;
    end
else
    obj.use_mex_to_read_ = false;
end

obj.filename_ = filename;
if use_mex_to_read
    [root_nx_path,nxsqw_version] = find_root_nexus_dir(filename,'NXSQW');
    if isempty(root_nx_path)
        error('HDF_PIX_GROUP:invalid_argument',...
            'Attempting to open pixel group for read only access but the file does not contain pixel information');
    end
    obj.nxsqw_version_ = nxsqw_version;
    obj.use_mex_to_read_ = true;
    obj.nexus_group_name_ = root_nx_path(2:end);
    if ~isempty(obj.mex_read_handler_ )
        obj.mex_read_handler_ = hdf_mex_reader('close',obj.mex_read_handler_);
    end
    obj.mex_read_handler_ = hdf_mex_reader('init',filename,obj.nexus_group_name_);
else
    [file_id,nexus_group_name,fid,file_h,nxsqw_version] = open_or_create_nxsqw_head(filename);
    obj.nexus_group_name_ = nexus_group_name;
    obj.nxsqw_version_ = nxsqw_version;
    
    if isempty(file_h)
        obj.fid_ = file_id;
    else
        obj.fid_ = file_id;
        obj.old_style_fid_ = file_id;
    end
end


group_name = 'pixels';


if use_mex_to_read
    [~,~,obj.max_num_pixels_ ,obj.chunk_size_ ,obj.cache_nslots_,obj.cache_size_] =...
        hdf_mex_reader('get_file_info',obj.mex_read_handler_);
    % pixels range:
    obj.fid_ = H5F.open(filename);
    obj.pix_group_id_ = H5G.open(obj.fid_,[obj.nexus_group_name_,'/',group_name]);
    if obj.pix_group_id_<0
        error('HDF_PIX_GROUP:runtime_error',...
            'can not open pixels group');
    end    
    read_pix_range_(obj);
else
    obj.pix_data_id_ = H5T.copy('H5T_NATIVE_FLOAT');
    if H5L.exists(fid,group_name,'H5P_DEFAULT')
        open_existing_dataset_matlab_(obj,fid,pix_size_defined,n_pixels,chunk_size,group_name);
        read_pix_range_(obj);
    else
        if nargin<1
            error('HDF_PIX_GROUP:invalid_argument',...
                'the pixels group does not exist but the size of the pixel dataset is not specified')
        end
        if ~pix_size_defined
            error('HDF_PIX_GROUP:invalid_argument',...
                'New new pixels group beeing created within existing nxsqw file, but the pixel number in this group is not defined');
        end
        create_pix_dataset_(obj,fid,group_name,n_pixels,chunk_size);
        write_pix_range_(obj);
    end
    block_dims = [obj.chunk_size_,9];
    obj.io_mem_space_ = H5S.create_simple(2,block_dims,block_dims);
    obj.io_chunk_size_ = obj.chunk_size_;
end

