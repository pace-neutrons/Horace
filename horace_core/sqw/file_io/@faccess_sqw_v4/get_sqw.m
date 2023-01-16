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


sqw_skel = struct('main_header',[],'experiment_info',[],'detpar',[], ...
    'data',[],'pix',[]);

if opts.head || opts.his
    skip_blocks = {'bl__det_par','bl_data_nd_data',...
        'bl_pix_metadata','bl_pix_data_wrap'};
else
    skip_blocks = {'bl_pix_metadata','bl_pix_data_wrap'};
end
[obj,sqw_skel] = obj.get_all_blocks(sqw_skel,'ignore_blocks',skip_blocks);

if ~(opts.head || opts.his)
    sqw_skel.data = DnDBase.dnd(sqw_skel.data.metadata,sqw_skel.data.nd_data);
    sqw_skel.experiment_info = Experiment([],sqw_skel.experiment_info.instruments, ...
        sqw_skel.experiment_info.samples,sqw_skel.experiment_info.expdata);    
end


% CRYSTAL ALIGNMENT FIXTURE: #TODO: #892 modify  and remove!
proj = sqw_skel.data.proj;
if isa(proj,'ortho_proj')
    header_av = sqw_skel.experiment_info.header_average();
    sqw_skel.data.proj = proj.set_ub_inv_compat(header_av.u_to_rlu(1:3,1:3));
end

if opts.nopix
    sqw_skel = rmfield(sqw_skel,'pix');
else
    sqw_skel.pix = PixelDataBase.create(obj, opts.pixel_page_size,opts.noupgrade);
end


if opts.legacy
    sqw_object   = sqw_skel.main_header;
    varargout{1} = sqw_skel.experiment_info;
    varargout{2} = sqw_skel.detpar;
    varargout{3} = sqw_skel.data;
    if isfield(sqw_skel,'pix')
        varargout{4} = sqw_skel.pix;
    else
        varargout{4} = [];
    end
elseif opts.head || opts.his
    sqw_object             = sqw_skel;
    sqw_object.num_pixels  = sqw_skel.pix.npix;
else
    sqw_object = sqw(sqw_skel);
    if  ~(opts.keep_original || opts.verbatim)
        sqw_object.pix.file_path = obj.full_filename;
    end
end


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
    'legacy' ...
    };

defailt_page_size = config_store.instance().get_value('hor_config','mem_chunk_size');
kwargs = struct('pixel_page_size', defailt_page_size);

for flag_idx = 1:numel(flags)
    kwargs.(flags{flag_idx}) = false;
end

parser_opts = struct('prefix', '-', 'prefix_req', false);
[~, opts, ~, ~, ok, mess] = parse_arguments(argi, kwargs, flags, ...
    parser_opts);

if ~ok
    error('HORACE:faccess_sqw_v3_:invalid_argument', mess);
end

opts.verbatim = opts.verbatim || opts.hverbatim;


function out = replace_h(inp)
if strcmp(inp,'-h')
    out = '-his';
else
    out  = inp;
end
