function varargout = data_structure_type_name(w)
% Determine data type of the data field of an sqw data structure
%
%   >> [data_type_name,sparse_fmt,flat] = data_structure_type_name(w)
%   >> [data_type_name,sparse_fmt,flat,ok,mess] = data_structure_type_name(w)
%
% Input:
% ------
%   w       sqw object or data structure (sqw-type or dnd-type)
%          Must have either the standard sqw format i.e. four fields named:
%               main_header, header, detpar, data
%
%          or one of the flat format buffer structures: i.e. with fields
%               non-sparse: npix, pix
%               sparse:     sz, nfiles, ndet, ne_max, npix, npix_nz, pix_nz, pix
%                          (sz      = Size of npix array when in non-sparse format
%                           nfiles  = 1 (single spe file) NaN (more than one)
%                           ndet    = no. detectors; ne=column vector of
%                           ne_max  = max. no. en bins in the spe files)
%
% Output:
% -------
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
%                               w.data: p, npix, npix_nz, pix_nz, pix are required
%                       *OR* Flat structure with fields:
%                               sz nfiles, ndet, ne_max, npix, npix_nz, pix_nz, pix
%
%   sparse_fmt      Indicates if data has sparse format or not:
%                       =true  if data is sparse format
%                       =false if data is sparse
%
%   flat            If the data has one of the buffer formats, then
%                       =true  if the data structure is flat
%                       =false if has structure of an sqw object
%
%   ok              No error found, ok=true; otherwise ok=false
%
%   mess            If empty, then all OK; otherwise contains error message
%                   If mess is not a return argument, then if an error is
%                  encountered then function will throw an error.
%
% NOTE: This is not a robust routine - it assumes that the data structure
%       actually has one of the above formats.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


ok=true;
mess='';

if isa(w,'sqw') || isfield(w,'data')    % catch case of sqw object as well as sqw structure
    data=w.data;
    % Take the presence or absence of a signal array as the defining quality of dnd or sqw
    %(We assume that the input is one of the acceptable cases, and therefore if signal is
    % present, the input can only be dnd or sqw type)
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
    
elseif isstruct(w)
    % Check carefully that the correct fields are present for flat format buffer structure
    % as it will be easy to get this wrong when constructing the structure on the fly
    if isfield(w,'npix') && isfield(w,'pix')
        if isfield(w,'sz') && isfield(w,'ndet') && isfield(w,'ne_max') && isfield(w,'npix_nz') && isfield(w,'pix_nz')
            sparse_fmt=true;
            data_type_name = 'buffer_sp';
        else
            sparse_fmt=false;
            data_type_name = 'buffer';
        end
        flat=true;
    else
        ok=false;
        mess='Data structure does not have a valid set of fields';
        data_type_name='';
        sparse_fmt=false;
        flat=false;
    end
    
else
    % Invalid data type
    ok=false;
    mess='Invalid data type';
    data_type_name='';
    sparse_fmt=false;
    flat=false;
end

% Fill output
nout=nargout;
if ~ok && nout<=3   % throw error if there is a problem and ok is not a return argument
    error(mess)
end
if nout>=1, varargout{1}=data_type_name; end
if nout>=2, varargout{2}=sparse_fmt; end
if nout>=3, varargout{3}=flat; end
if nout>=4, varargout{4}=ok; end
if nout>=5, varargout{5}=mess; end
