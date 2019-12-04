function [dnd_object,varargout] = get_dnd (obj,varargin)
% Load an sqw file from disk
%
%   >> dnd_object = obj.get_dnd()
%   >> dnd_object = obj.get_dnd('-h')
%   >> dnd_object = obj.get_dnd('-his')
%   >> dnd_object = obj.get_dnd('-hverbatim')
%   >> dnd_object = obj.get_dnd('-hisverbatim')
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
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

if nargin>1
    % replace single '-h' with head
    argi = cellfun(@replace_h,varargin,'UniformOutput',false);
else
    argi = {};
end
opt = {'-head','-his','-hverbatim','-verbatim','-nopix'};
% suppress options which are irrelevant
[ok,mess,~,~,hverbatim,verbatim,~,argi] = parse_char_options(argi,opt);
verbatim = hverbatim||verbatim;
if ~ok
    error('SQW_FILE_IO:invalid_argument',['get_dnd: ',mess]);
end

if verbatim
    opt = [argi{:},{'-nopix','-noclass','-verbatim'}];
else
    opt = [argi{:},{'-nopix','-noclass'}];    
end

% can not call get_data@dnd_binfile_common directly!
if nargout > 1
    [dnd_object,varargout]  = get_dnd@dnd_binfile_common(obj,opt{:});
else
    dnd_object  = get_dnd@dnd_binfile_common(obj,opt{:});    
    varargout = {};
end


function out = replace_h(inp)
if strcmp(inp,'-h')
    out = '-his';
else
    out  = inp;
end
