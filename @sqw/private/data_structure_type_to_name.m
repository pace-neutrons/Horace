function [data_type_name,sparse_fmt] = data_structure_type_to_name(data_type)
% Convert data_type to data_type_name
%
%   >> [data_type_name,sparse_fmt] = data_structure_type_to_name(data_type)
%
% Input:
% ------
%   data_type       Structure indicating the data type: fields are true or false:
%                       data_type.sqw_data      sqw object or sqw structure, either
%                                              sqw or dnd type (sparse or non-sparse)
%                       data_type.sqw_type      sqw-type data (sparse or non-sparse)
%                       data_type.dnd_type      dnd-type data (sparse or non-sparse)
%                       data_type.buffer_type   buffer data  (sparse or non-sparse)
%                       data_type.h'            header part of data structure only
%                       data_type.dnd'          dnd object or dnd structure
%                       data_type.dnd_sp'       dnd structure, sparse format
%                       data_type.sqw'          sqw object or sqw structure
%                       data_type.sqw_'         sqw structure withut pix array
%                       data_type.sqw_sp'       sqw structure, sparse format
%                       data_type.sqw_sp_'      sqw structure, sparse format without
%                       data_type.buffer'       npix, pix
%                       data_type.buffer_sp'    npix,npix_nz,pix_nz,pix
%
%                   One and only one of the fields 'h'...'buffer_sp' will be true
%
% Output:
% -------
%   data_type_nam   Name of data type:
%                       ='h'         header part of data structure only
%                                   i.e. fields filename,...,uoffset,...,dax
%
%                       ='dnd'       dnd object or dnd structure
%                       ='dnd_sp'    dnd structure, sparse format
%
%                       ='sqw'       sqw object or sqw structure
%                       ='sqw_'      sqw structure withut pix array
%
%                       ='sqw_sp'    sqw structure, sparse format
%                       ='sqw_sp_'   sqw structure, sparse format without
%                                   npix_nz,pix_nz,pix arrays
%
%                       ='buffer'    npix, pix
%                       ='buffer_sp' npix,npix_nz,pix_nz,pix
%
%   sparse_fmt      Indicates if data has sparse format or not:
%                       =true  if data is sparse format
%                       =false if data is sparse


% Original author: T.G.Perring
%
% $Revision: 885 $ ($Date: 2014-07-29 17:35:24 +0100 (Tue, 29 Jul 2014) $)

names=fieldnames(data_type);
val=cell2mat(struct2cell(data_type));
ind=find(val,1,'last');

data_type_name=names{ind};
if numel(data_type_name)>3 && any(strcmp(data_type_name(end-2:end),{'_sp','sp_'}))
    sparse_fmt=true;
else
    sparse_fmt=false;
end
