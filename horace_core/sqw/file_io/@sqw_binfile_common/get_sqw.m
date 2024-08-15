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
    detpar = obj.get_detpar();
    if ~isempty(detpar)
        if  isstruct(detpar) && IX_detector_array.check_detpar_parms(detpar)
            detector = IX_detector_array(detpar);
            det_arrays = exp_info.detector_arrays;
            if exp_info.detector_arrays.n_runs == 0
                det_arrays = det_arrays.add_copies_(detector, exp_info.n_runs);
                exp_info.detector_arrays = det_arrays;

            elseif exp_info.detector_arrays.n_runs == exp_info.n_runs
                exp_info.detector_arrays = exp_info.detector_arrays.replace_all(detector);
            else
                error('HORACE:get_sqw:invalid_data', ...
                    ['the detector arrays input with exp_info are neither zero length',...
                    'nor as long as the number of runs in exp_info.\n', ...
                    'the formation of exp_info upstream may be faulty.']);
            end
        else
            error('HORACE:get_sqw:invalid_data', ...
                'detpar input is not a struct as per this file format');
        end
    else
        ; % there was no detpar info in the file; currently do nothing, not an error state
    end
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
%
hav     = exp_info.header_average();
al_info = dnd_data_alignment(sqw_struc.data,hav);
%
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
if ~isempty(al_info)
    sqw_struc.pix.alignment_matr = al_info.rotmat;
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
%
if opts.legacy
    if nargout == 1
        sqw_object   = sqw_struc;
    elseif nargout == 2
        sqw_object   = sqw_struc;
        varargout{1} = obj;
    else
        sqw_object   = sqw_struc.main_header;
        varargout{1} = sqw_struc.experiment_info;
        varargout{2} = sqw_struc.detpar;
        varargout{3} = sqw_struc.data;
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

