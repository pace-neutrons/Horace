function [data_type_name,sparse_fmt] = data_structure_type_name(data)
% Determine data type of the data field of an sqw data structure
%
%   >> [data_type,data_type_name,sparse_fmt] = data_structure_type_name(data)
%
% Input:
% ------
%   data            Data structure
%
% Output:
% -------
%   data_type_name  Name of data type:
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
%
% NOTE: This is not a robust routine - it assumes that the data structure
%       actually has one of the above formats.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

data_type=struct('sqw_data',false,'sqw_type',false,'dnd_type',false,'buffer_type',false,...
    'h',false,'dnd',false,'dnd_sp',false,'sqw_',false,'sqw_sp_',false,'sqw',false,'sqw_sp',false,...
    'buffer',false,'buffer_sp',false);

% Take the presence or absence of a signal array as the defining quality of dnd or sqw
if isfield(data,'s')
    if issparse(data.s)
        sparse_fmt=true;
        if isfield(data,'pix');
            data_type_name = 'sqw_sp';
        elseif isfield(data,'urange');
            data_type_name = 'sqw_sp_';
        else
            data_type_name = 'dnd_sp';
        end
    else
        if isfield(data,'pix');
            data_type_name = 'sqw';
        elseif isfield(data,'urange');
            data_type_name = 'sqw_';
        else
            data_type_name = 'dnd';
        end
    end
else
    if isfield(data,'npix') && isfield(data,'pix')
        if isfield(data,'npix_nz') && isfield(data,'pix_nz')
            data_type_name='buffer_sp';
            sparse_fmt=true;
        else
            data_type_name='buffer';
            sparse_fmt=false;
        end
    else
        data_type_name = 'h';
        sparse_fmt=false;   % actually meaningless here, but must return a value
    end
end
