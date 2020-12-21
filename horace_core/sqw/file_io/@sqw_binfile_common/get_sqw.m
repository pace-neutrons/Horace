function [sqw_object,varargout] = get_sqw (obj,varargin)
% Load an sqw file from disk
%
%   >> sqw_object = obj.get_sqw()
%   >> sqw_object = obj.get_sqw('-h')
%   >> sqw_object = obj.get_sqw('-his')
%   >> sqw_object = obj.get_sqw('-hverbatim')
%   >> sqw_object = obj.get_sqw('-hisverbatim')
%   >> sqw_object = obj.get_sqw('-nopix')
%
% Input:
% --------
%   infile      File name, or file identifier of open file, from which to read data
%
%   opt         [optional] Determines which fields to read:
%                   '-h'            - header block without instrument and sample information, and
%                                   - data block fields: filename, filepath, title, alatt, angdeg,...
%                                                          uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%                                    (If the file was written from a structure of type 'b' or 'b+', then
%                                    urange does not exist, and the output field will not be created)
%                   '-his'          - header block in full i.e. with without instrument and sample information, and
%                                   - data block fields as for '-h'
%                   '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%                   '-hisverbatim'  Similarly as for '-his'
%                   '-nopix'        Pixel information not read (only meaningful for sqw data type 'a')
%                   '-legacy'       Return result in legacy format, e.g. 4
%                                   fields, namely: main_header, header,
%                                   detpar and data
%
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
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
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)

opt = {'-head','-his','-hverbatim','-verbatim','-nopix','-legacy'};
if nargin>1
    % replace single '-h' with head
    argi = cellfun(@replace_h,varargin,'UniformOutput',false);
else
    argi = {};
end
[ok,mess,opt_h,opt_his,hverbatim,verbatim,opt_nopix,legacy,argi] = parse_char_options(argi,opt);
if ~ok
    error('SQW_FILE_IO:invalid_argument',mess);
end
verbatim = verbatim||hverbatim;
if numel(argi)>0
    error('SQW_BINFILE_COMMON:invalid_argument',...
        'Unrecognised options %s to get_sqw',argi{:});
end


sqw_struc = struct('main_header',[],'header',[],'detpar',[],'data',[]);


% Get main header
% ---------------
if verbatim
    sqw_struc.main_header =  obj.get_main_header('-verbatim');
else
    sqw_struc.main_header =  obj.get_main_header();
end
%
% Get cellarray of headers for each contributing spe file
% ------------------------------------------
headers  = obj.get_header('-all');
%
% Get detector parameters
% -----------------------
if ~(opt_h||opt_his)
    sqw_struc.detpar = obj.get_detpar();
end

% Get data
% --------
if verbatim
    opt1 = {'-verbatim'};
else
    opt1 = {};
end

if (opt_h||opt_his)
    opt2 = {'-head'};
else
    opt2= {};
end
if opt_nopix
    opt3={'-nopix'};
else
    opt3={};
end

data_opt={opt1{:},opt2{:},opt3{:}};
sqw_struc.data = obj.get_data(data_opt{:});

sqw_struc.header = headers;
if legacy
    sqw_object = sqw_struc.main_header;
    varargout{1} = sqw_struc.header;
    varargout{2} = sqw_struc.detpar;
    varargout{3} = sqw_struc.data;
elseif opt_h || opt_his
    sqw_object  = sqw_struc;
else
    sqw_object = sqw_old(sqw_struc);
end

function out = replace_h(inp)
if strcmp(inp,'-h')
    out = '-his';
else
    out  = inp;
end

