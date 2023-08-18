function [sqw_object,varargout] = get_sqw(obj, varargin)
% Load an sqw file from disk
%
%   >> sqw_object = obj.get_sqw()
%   >> sqw_object = obj.get_sqw('-h')
%   >> sqw_object = obj.get_sqw('-his')
%   >> sqw_object = obj.get_sqw('-keep_original')
%   >> sqw_object = obj.get_sqw('-hisverbatim')
%   >> sqw_object = obj.get_sqw('-nopix')
%   >> sqw_object = obj.get_sqw('-file_backed')
%
% Input:
% --------
% infile      File name, or file identifier of open file, from which to read data
% Optional: [optional] Determines which fields to read and how to tread the read data:
%
%   opt
%
%  '-h'            - header block without instrument and sample information, and
%                  - data block fields: filename, filepath, title, alatt, angdeg,...
%                    uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,img_db_range]
%                    (If the file was written from a structure of type 'b' or 'b+', then
%                    img_db_range does not exist, and the output field will not be created)
%  '-his'          - header block in full i.e. without instrument and sample information, and
%                  - data block fields as for '-h'
%  '-hverbatim'    Same as '-h' except that the file name as stored in the main_header and
%                  data sections are returned as stored, not constructed from the
%                  value of fopen(fid). This is needed in some applications where
%                  data is written back to the file with a few altered fields.
%  '-hisverbatim'  Similarly as for '-his'
%  '-nopix'        Pixel information not read (only meaningful for sqw data type 'a')
%  '-legacy'       Return result in legacy format, e.g. 4
%                  fields, namely: main_header, header,
%                  detpar and data
%  '-noupgrade' or if it is old file format, do not do
%  '-norange'      expensive calculations, necessary for
%                  upgrading file format to recent version
%
% Default: read all fields of whatever is the sqw data type contained in the file ('b','b+','a','a-')
%

% Output:
% --------
%  fully formed sqw object
%
%
% Original author: T.G.Perring
%
opts = horace_binfile_interface.parse_get_sqw_args(varargin{:});

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

if ~opts.nopix && obj.npixels>0
    if opts.noupgrade || opts.norange
        argi = {'-norange'};
    else
        argi = {};
    end
    if opts.force_pix_location
        if opts.file_backed
            sqw_struc.pix = PixelDataFileBacked(obj,argi{:});
        else
            sqw_struc.pix = PixelDataMemory(obj,argi{:});
        end
    else
        if opts.file_backed
            argi = [argi(:),'-filebacked'];
        end
        sqw_struc.pix = PixelDataBase.create(obj,argi{:});
    end
end

sqw_struc.experiment_info = exp_info;
old_file = ~sqw_struc.main_header.creation_date_defined;
% run_id map in any form, so it is often tried to be restored from filename.
% here we try to verify, if this restoration is correct if we can do that
% without critical drop in performance.
if ~opts.nopix && (sqw_struc.pix.num_pixels > 0) && old_file
    % try to update pixels run id-s
    sqw_struc = update_pixels_run_id(sqw_struc);
end
% needed to support  legacy alignment, where u_to_rlu matrix is multiplied
% by alignment rotation matrix
header_av = exp_info.header_average;
if isfield(header_av,'u_to_rlu') && ~isempty(header_av.u_to_rlu)
    u_to_rlu  = header_av.u_to_rlu(1:3,1:3);
    if any(abs(subdiag_elements(u_to_rlu))>4*eps('single')) % if all 0, its inverted B-matrix so certainly
        proj = sqw_struc.data.proj;         % no alignment (lattice may have changed
        % but this is reflected elsewhere), otherwise legacy alignment.
        sqw_struc.data.proj = proj.set_ub_inv_compat(header_av.u_to_rlu);
    end
end
%
if opts.legacy
    if nargout == 1
        sqw_object  = sqw_skel;
    elseif nargout == 2
        sqw_object   = sqw_skel;
        varargout{1} = obj;
    else
        sqw_object   = sqw_skel.main_header;
        varargout{1} = sqw_skel.experiment_info;
        varargout{2} = sqw_skel.detpar;
        varargout{3} = sqw_skel.data;
        if isfield(sqw_skel,'pix')
            varargout{4} = sqw_skel.pix;
        else
            varargout{4} = [];
        end
    end
elseif opts.head || opts.his || opts.sqw_struc
    sqw_object  = sqw_struc;
else
    sqw_object = sqw(sqw_struc);
end
if nargout>1
    varargout{1} = obj;
end

