function [data_type,sparse_fmt] = data_structure_name_to_type(data_type_name)
% Convert data_type_name to data_type
%
%   >> [data_type,sparse_fmt] = data_structure_name_to_type(data_type_name)
%
% Input:
% ------
%   data_type_name  Name of data type:
%               ='h'         header part of w.data only is required
%                           i.e. fields filename,...,uoffset,...,dax
%                           [The fields main_header, header, detpar
%                           must exist but can be empty - they are ignored]
%
%               ='dnd'       dnd object or dnd structure
%               ='dnd_sp'    dnd structure, sparse format
%
%               ='sqw'       sqw object or sqw structure
%               ='sqw_sp'    sqw structure, sparse format
%
%               ='sqw_'      sqw structure without pix array
%               ='sqw_sp_'   sqw structure, sparse format, without
%                           npix_nz,pix_nz,pix arrays
%
%               ='buffer'    sqw structure, only w.data.npix, w.data.pix required
%                           [The fields main_header, header, detpar
%                           must exist but can be empty - they are ignored]
%                       *OR* Flat structure with only npix, pix required
%
%               ='buffer_sp' sqw structure, required fields:
%                               w.header: en 
%                               w.detpar: <all fields>
%                               w.data: npix, npix_nz, pix_nz, pix are required
%                       *OR* Flat structure with fields:
%                               sz, nfiles, ndet, ne_max, npix, npix_nz, pix_nz, pix
%
% Output:
% -------
%   data_type       Structure indicating the data type: fields are true or false:
%                       data_type.sqw_data      sqw object or sqw structure, either
%                                              sqw or dnd type (sparse or non-sparse)
%                       data_type.sqw_type      sqw-type data (sparse or non-sparse)
%                       data_type.dnd_type      dnd-type data (sparse or non-sparse)
%                       data_type.buffer_data   buffer data  (sparse or non-sparse)
%                       data_type.h'            header part of data structure only
%                       data_type.dnd'          dnd object or dnd structure
%                       data_type.dnd_sp'       dnd structure, sparse format
%                       data_type.sqw'          sqw object or sqw structure
%                       data_type.sqw_'         sqw structure withut pix array
%                       data_type.sqw_sp'       sqw structure, sparse format
%                       data_type.sqw_sp_'      sqw structure, sparse format, without
%                                              npix_nz,pix_nz,pix arrays
%                       data_type.buffer'       buffer data
%                       data_type.buffer_sp'    buffer data, sparse format
%
%                   One and only one of the fields 'h'...'buffer_sp' will be true
%
%                   Note: the structure contains reducdant information; the
%                   first four fields are summary fields whose values can
%                   be determined from the later fields.


% Original author: T.G.Perring
%
% $Revision: 885 $ ($Date: 2014-07-29 17:35:24 +0100 (Tue, 29 Jul 2014) $)


data_type=struct('sqw_data',false,'sqw_type',false,'dnd_type',false,'buffer_data',false,...
    'h',false,'dnd',false,'dnd_sp',false,'sqw_',false,'sqw_sp_',false,'sqw',false,'sqw_sp',false,...
    'buffer',false,'buffer_sp',false);

data_type.(data_type_name)=true;

if data_type.sqw || data_type.sqw_sp
    data_type.sqw_type=true;
elseif data_type.dnd || data_type.dnd_sp
    data_type.dnd_type=true;
elseif data_type.buffer || data_type.buffer_sp
    data_type.buffer_data=true;
end

if data_type.sqw_type || data_type.dnd_type
    data_type.sqw_data=true;
end

if numel(data_type_name)>3 && any(strcmp(data_type_name(end-2:end),{'_sp','sp_'}))
    sparse_fmt=true;
else
    sparse_fmt=false;
end
