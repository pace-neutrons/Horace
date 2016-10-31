function res = get_sqw (obj,varargin)
% Load an sqw file from disk
%
%   >> dnd_object = obj.get_sqw()
%   >> dnd_object = obj.get_sqw('-verbatim')
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%
%   opt         [optional] Determines which fields to read:
%                                    (If the file was written from a structure of type 'b' or 'b+', then
%                                    urange does not exist, and the output field will not be created)
%                   '-verbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
%
% Output:
% --------
%  fully formed sqw object
%
%   data        Output data structure actually read from the file. Will be one of:
%                   type 'h'    fields: filename,...,uoffset,...,dax[,urange]
%                   type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                   type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                   type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%                   type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%               The final field urange is present for type 'h' if the header information was read from an sqw-type file.
%
% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
[ok,mess,verbatim,hver,~] =  parse_char_options(varargin,{'-verbatim','-hverbatim'});
if ~ok
    error('DND_BINFILE_COMMON:invalid_arguments',mess);
end
verbatim = verbatim || hver;
if verbatim
    dat = obj.get_data('-verbatim');
else
    dat = obj.get_data();    
end
ndim = obj.num_dim;

warning('off','MATLAB:structOnObject');
clob = onCleanup(@()warning('on','MATLAB:structOnObject'));
switch ndim
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
        error('DND_BINFILE_COMMON:runtime_error',...
            'get_sqw: unsupported number of dimensions (%d) read from binary file',ndim)
end
