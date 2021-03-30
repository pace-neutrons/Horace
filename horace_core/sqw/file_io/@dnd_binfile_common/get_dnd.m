function [res,varargout] = get_dnd (obj,varargin)
% Load an sqw/dnd file from disk and return the result as dnd object of
% appropriate dimensions.
%
%   >> dnd_object = obj.get_dnd()
%   >> dnd_object = obj.get_dnd('-verbatim')
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%
%   opt         [optional] Determines which fields to read:
%                                    (If the file was written from a structure of type 'b' or 'b+', then
%                                    img_range does not exist, and the output field will not be created)
%                 '-verbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                data sections are returned as stored, not constructed from the
%                                value of fopen(fid). This is needed in some applications where
%                                data is written back to the file with a few altered fields.
%                   '-hverbatim'
%                   '-legacy'   -- instead of the object, returns the sqw
%                                  file structure, with all sqw fields
%                                  except data beeing empty
%
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
%
% Output:
% --------
%  fully formed sqw object
%
%   data        Output data structure actually read from the file. Will be one of:
%                   type 'h'    fields: filename,...,uoffset,...,dax[,img_range]
%                   type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                   type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                   type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,img_range
%                   type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,img_range,pix
%               The final field img_range is present for type 'h' if the header information was read from an sqw-type file.
%
% Original author: T.G.Perring
%
%
[ok,mess,verbatim,hver,legacy,argi] =  parse_char_options(varargin,{'-verbatim','-hverbatim','-legacy'});
if ~ok
    error('SQW_FILE_IO:invalid_arguments',mess);
end
verbatim = verbatim || hver;
if verbatim
    argi = {argi{:},'-verbatim'};
end
dat = obj.get_data(argi{:});
ndim = obj.num_dim;
%
if legacy
    res = struct([]); % main header
    varargout{1} = struct([]); % header
    varargout{2} = struct([]); % detpar;
    varargout{3} = dat;      % data
    return
end

warning('off','MATLAB:structOnObject');
clob = onCleanup(@()warning('on','MATLAB:structOnObject'));
switch ndim %TODO: the dnd constructor should deal with this switch.
    case 0
        res = d0d(dat);
    case 1
        res = d1d(dat);
    case 2
        res = d2d(dat);
    case 3
        res = d3d(dat);
    case 4
        res = d4d(dat);
    otherwise
        error('SQW_FILE_IO:runtime_error',...
            'get_sqw: unsupported number of dimensions (%d) read from binary file',ndim)
end
varargout = {};

