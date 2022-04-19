function [sqw_object,varargout] = get_sqw (obj, varargin)
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
%   data        Output data structure actually read from the file. Will be one of:
%                   type 'h'    fields: filename,...,uoffset,...,dax[,img_db_range]
%                   type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                   type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                   type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,img_db_range
%                   type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,img_db_range,pix
%               The final field img_db_range is present for type 'h' if the header information was read from an sqw-type file.
%
% Original author: T.G.Perring
%
opts = parse_args(obj, varargin{:});

sqw_struc = struct('main_header',[],'experiment_info',[],'detpar',[],'data',[]);

% Get main header
% ---------------
if opts.verbatim
    sqw_struc.main_header =  obj.get_main_header('-verbatim');
else
    sqw_struc.main_header =  obj.get_main_header();
end

% Get cell array of headers for each contributing spe file
% ------------------------------------------
[headers,~,runid_map]  = obj.get_header('-all');

% Get detector parameters
% -----------------------
if ~(opts.head||opts.his)
    sqw_struc.detpar = obj.get_detpar();
end

% Get data
% --------
if opts.verbatim
    opt1 = {'-verbatim'};
else
    opt1 = {};
end
if (opts.head || opts.his)
    opt2 = {'-head'};
else
    opt2 = {};
end
if opts.nopix
    opt3={'-nopix'};
else
    opt3={};
end
if opts.noupgrade
    opt4={'-noupgrade'};
else
    opt4={};
end


data_opt= [opt1, opt2, opt3, opt4];
sqw_struc.data = obj.get_data(data_opt{:}, 'pixel_page_size', opts.pixel_page_size);

sqw_struc.experiment_info = headers;
old_file = datetime(obj.creation_date)<datetime('01-Mar-2022'); % old file did not store 
% run_id map in any form, so it is often tried to be resored from filename. 
% here we try to verify, if this restoration is correct if we can do that
% without critical drop in performance.
if (sqw_struc.data.pix.num_pixels >0 && sqw_struc.data.pix.n_pages == 1) && ...
    old_file
    runid = unique(sqw_struc.data.pix.run_idx);
    file_id = runid_map.keys;
    file_id = [file_id{:}];
    if ~all(ismember(runid,file_id)) || old_file % old style pixel data, run_id-s 
        % have been recalculated
        % use the fact that the headers were recalculated as subsequent numbers 
        % going from 1 to n_headers
        id=1:headers.n_runs;        
        new_runid_map = containers.Map(id,id);  
        inf = sqw_struc.experiment_info.expdata;
        for i=1:numel(inf)
            inf(i).run_id = id(i);
        end
        sqw_struc.experiment_info.expdata = inf;
        %
        [exp_info,runid_map] = sqw_struc.experiment_info.get_subobj(runid,new_runid_map,false);
        sqw_struc.experiment_info = exp_info;
        sqw_struc.runid_map = runid_map;
        sqw_struc.main_header.nfiles = exp_info.n_runs;
        % 
    end
end
sqw_struc.runid_map = runid_map;
if opts.legacy
    sqw_object = sqw_struc.main_header;
    varargout{1} = sqw_struc.experiment_info;
    varargout{2} = sqw_struc.detpar;
    varargout{3} = sqw_struc.data;
    varargout{4} = sqw_struc.runid_map;    
elseif opts.head || opts.his
    sqw_object  = sqw_struc;
else
    sqw_object = sqw(sqw_struc);
end

end  % function


% -----------------------------------------------------------------------------
function opts = parse_args(varargin)
    if nargin > 1
        % replace single '-h' with head
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
        'nopix', ...
        'legacy' ...
    };
    kwargs = struct('pixel_page_size', PixelData.DEFAULT_PAGE_SIZE);
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
