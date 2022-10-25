function [sqw_object,varargout] = get_sqw(obj, varargin)
% Load an sqw file from disk
%
%   >> sqw_object = obj.get_sqw()
%   >> sqw_object = obj.get_sqw('-h')
%   >> sqw_object = obj.get_sqw('-his')
%   >> sqw_object = obj.get_sqw('-keep_original')
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
%                                                          uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,img_db_range]
%                                    (If the file was written from a structure of type 'b' or 'b+', then
%                                    img_db_range does not exist, and the output field will not be created)
%                   '-his'          - header block in full i.e. without instrument and sample information, and
%                                   - data block fields as for '-h'
%                   '-hverbatim'   Same as '-h' except that the file name as stored in the main_header and
%                                  data sections are returned as stored, not constructed from the
%                                  value of fopen(fid). This is needed in some applications where
%                                  data is written back to the file with a few altered fields.
%                   '-hisverbatim'  Similarly as for '-his'
%                   '-nopix'        Pixel information not read (only meaningful for sqw data type 'a')
%                   '-legacy'       Return result in legacy format, e.g. 4
%                                   fields, namely: main_header, header,
%                                   detpar and data
%                   '-noupgrade'    if it is old file format, do not do
%                                   expensive calculations, necessary for
%                                   upgrading file format to recent version
%
%               Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%
% Keyword Arguments:
% ------------------
%   pixel_page_size    The maximum amount of memory to allocate to holding
%                      pixel data. This argument is passed to the PixelData
%                      constructor's 'mem_alloc' argument.
%                      The value should have units of bytes.
%
% Output:
% --------
%  fully formed sqw object
%
%
% Original author: T.G.Perring
%
opts = parse_args(obj, varargin{:});

sqw_struc = struct('main_header',[],'experiment_info',[],'detpar',[], ...
    'data',[],'pix',[]);

% Get main header
% ---------------
if opts.keep_original || opts.verbatim
    sqw_struc.main_header =  obj.get_main_header('-keep_original');
else
    sqw_struc.main_header =  obj.get_main_header();
end

% Get cell array of headers for each contributing spe file
% ------------------------------------------
[exp_info,~]  = obj.get_exp_info('-all');

% Get detector parameters
% -----------------------
if ~(opts.head||opts.his)
    sqw_struc.detpar = obj.get_detpar();
end

% Get data
% --------
if opts.verbatim || opts.keep_original
    opt1 = {'-verbatim'};
else
    opt1 = {};
end
if (opts.head || opts.his)
    opt2 = {'-head'};
else
    opt2 = {};
end


data_opt= [opt1, opt2];
sqw_struc.data = obj.get_data(data_opt{:});
proj = sqw_struc.data.proj;
header_av = exp_info.header_average();
sqw_struc.data.proj = proj.set_ub_inv_compat(header_av.u_to_rlu(1:3,1:3));

if ~opts.nopix && obj.npixels>0
    sqw_struc.pix = PixelDataBase.create(obj, opts.pixel_page_size,~opts.noupgrade, opts.file_backed);
end

sqw_struc.experiment_info = exp_info;
old_file = ~sqw_struc.main_header.creation_date_defined;
% run_id map in any form, so it is often tried to be restored from filename.
% here we try to verify, if this restoration is correct if we can do that
% without critical drop in performance.
if (sqw_struc.pix.num_pixels > 0) && old_file
    % try to update pixels run id-s
    sqw_struc = update_pixels_run_id(sqw_struc);
end

if opts.legacy
    sqw_object = sqw_struc.main_header;
    varargout{1} = sqw_struc.experiment_info;
    varargout{2} = sqw_struc.detpar;
    varargout{3} = sqw_struc.data;
    varargout{4} = sqw_struc.pix;
elseif opts.head || opts.his
    sqw_object  = sqw_struc;
else
    sqw_object = sqw(sqw_struc);
end

end  % function


% -----------------------------------------------------------------------------
function opts = parse_args(varargin)
if nargin > 1
    % replace single '-h' with his
    argi = cellfun(@replace_h, varargin, 'UniformOutput', false);
else
    argi = {};
end

flags = { ...
    'head', ...
    'his', ...
    'verbatim', ...
    'hverbatim', ...
    'hisverbatim', ...
    'noupgrade',...
    'keep_original',...
    'nopix', ...
    'legacy', ...
    };

kwargs = struct('pixel_page_size', PixelDataBase.DEFAULT_PAGE_SIZE, ...
                'file_backed', []);

for flag_idx = 1:numel(flags)
    kwargs.(flags{flag_idx}) = false;
end

parser_opts = struct('prefix', '-', 'prefix_req', false);
[~, opts, ~, ~, ok, mess] = parse_arguments(argi, kwargs, flags, ...
    parser_opts);

if ~ok
    error('SQW_FILE_IO:invalid_argument', mess);
end

opts.verbatim = opts.verbatim || opts.hverbatim;

end

function out = replace_h(inp)
if strcmp(inp,'-h')
    out = '-his';
else
    out  = inp;
end
end
