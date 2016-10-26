function sqw_object = get_sqw (obj,varargin)
% Load an sqw file from disk
%
%   >> sqw_object = obj.get_sqw()
%   >> sqw_object = obj.get_sqw('-h')
%   >> sqw_object = obj.get_sqw('-his')
%   >> sqw_object = obj.get_sqw('-hverbatim')
%   >> sqw_object = obj.get_sqw('-hisverbatim')
%   >> sqw_object = obj.get_sqw('-nopix')
%   >> sqw_object = obj.get_sqw(npix_lo, npix_hi)
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
%
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
%   npix_lo     -|- [optional] pixel number range to be read from the file
%   npix_hi     -|
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
% $Revision: 1184 $ ($Date: 2016-02-12 19:15:55 +0000 (Fri, 12 Feb 2016) $)

% Check options
opt_h=false;
opt_his=false;
verbatim=false;
opt_nopix=false;
pix_range=false;
opt_char={'-h','-his','-hverbatim','-hisverbatim','-nopix'};
if numel(varargin)==1 && ischar(varargin{1}) && any(strcmpi(varargin{1},opt_char))   % single option that is a character string
    if strcmpi(varargin{1},'-h')||strcmpi(varargin{1},'-hverbatim')
        opt_h=true;
    end
    if strcmpi(varargin{1},'-his')||strcmpi(varargin{1},'-hisverbatim')
        opt_his=true;
    end
    if strcmpi(varargin{1},'-hverbatim')||strcmpi(varargin{1},'-hisverbatim')
        verbatim=true;
    end
    if strcmpi(varargin{1},'-nopix')
        opt_nopix=true;
    end
    
elseif numel(varargin)==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
        isscalar(varargin{1}) && isscalar(varargin{2})
    pix_range=true;
    npix_lo=varargin{1};
    npix_hi=varargin{2};
    
elseif numel(varargin)>0
    error('SQW_BINFILE_COMMON:invalid_argument',...
        'Unrecognised options to get_sqw');
end

sqw_struc = struct('main_header',[],'header',[],'detpar',[],'data',[]);


% Get main header
% ---------------
if verbatim
    sqw_struc.main_header =  obj.get_main_header('-verbatim');
else
    sqw_struc.main_header =  obj.get_main_header();
end
% Get headers for each contributing spe file
% ------------------------------------------
n_files = obj.num_contrib_files;
headers = obj.get_header(1);
if n_files > 1
    headers = repmat(headers,1,n_files);
    for i=2:n_files
        headers(i) = obj.get_header(i);
    end
end
%
% Get detector parameters
% -----------------------
sqw_struc.detpar = obj.get_detpar();

% Get data
% --------
if (opt_h||opt_his) && ~verbatim
    data_opt={'-h'};
elseif (opt_h||opt_his) && verbatim
    data_opt={'-hverbatim'};
elseif opt_nopix
    data_opt={'-nopix'};
elseif pix_range
    data_opt={npix_lo,npix_hi};
else
    data_opt={};
end

sqw_struc.data = obj.get_data(data_opt{:});

instr = obj.get_instrument('-all');
sampl = obj.get_sample('-all');
for i=1:n_files
    if numel(instr) > 1
        headers(i).instrument = instr(i);
    else
        headers(i).instrument = instr ;
    end
    if numel(sampl) > 1
        headers(i).sample = sampl(i);
    else
        headers(i).sample = sampl;
    end
end
sqw_struc.header = headers;

sqw_object = sqw(sqw_struc);
