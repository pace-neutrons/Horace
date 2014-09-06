function [data_type_name,sparse_fmt,flat] = data_structure_type_name(w)
% Determine data type of the data field of an sqw data structure
%
%   >> [data_type,data_type_name,sparse_fmt] = data_structure_type_name(w)
%
% Input:
% ------
%   w               Data structure. Must have either the standard sqw format
%                  i.e. four fields named:
%                       main_header, header, detpar, data
%
%                  or one of the flat format buffer structures:
%                       non-sparse: npix, pix
%                       sparse:     ndet, ne, npix, npix_nz, pix_nz, pix
%                                  (ndet=no. detectors; ne=column vector of
%                                   number of energy bins in each spe file)
%
% Output:
% -------
%   data_type_name  Name of data type:
%                       ='h'         header part of data structure only
%                                   i.e. fields filename,...,uoffset,...,dax
%                                    The fields main_header, header, detpar
%                                   must exist but can be empty.
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
%                       ='buffer_sp' npix, npix_nz, pix_nz, pix
%
%   sparse_fmt      Indicates if data has sparse format or not:
%                       =true  if data is sparse format
%                       =false if data is sparse
%
%   flat            If the data has one of the buffer formats, then
%                       =true  if the data structure is flat
%                       =false if not
%
% NOTE: This is not a robust routine - it assumes that the data structure
%       actually has one of the above formats.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if isa(w,'sqw') || isfield(w,'data')    % catch case of object (isfield only seems to work on structures)
    data=w.data;
    % Take the presence or absence of a signal array as the defining quality of buffer, or dnd or sqw
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
            sparse_fmt=false;
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
                sparse_fmt=true;
                data_type_name = 'buffer_sp';
            else
                sparse_fmt=false;
                data_type_name = 'buffer';
            end
        else
            sparse_fmt=false;   % actually meaningless here, but must return a value
            data_type_name = 'h';
        end
    end
    flat=false;
    
else
    % Check carefully with correct fields are present for flat format buffer structure
    % as it will be easy to get this wrong when constructing the structure on the fly
    if isfield(w,'npix') && isfield(w,'pix')
        if isfield(w,'npix_nz') && isfield(w,'pix_nz') && isfield(w,'ndet') && isfield(w,'ne')
            sparse_fmt=true;
            data_type_name = 'buffer_sp';
        else
            sparse_fmt=false;
            data_type_name = 'buffer';
        end
    else
        error('Logic error in put_sqw functions. See T.G.Perring')
    end
    flat=true;
    
end
