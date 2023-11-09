function [sqw_object,varargout] = get_sqw(obj, varargin)
% Load an sqw object from sqw file on disk
%
%   >> sqw_object = obj.get_sqw()
%   >> sqw_object = obj.get_sqw(infile)
%   >> sqw_object = obj.get_sqw('-h')
%   >> sqw_object = obj.get_sqw('-his')
%   >> sqw_object = obj.get_sqw('-keep_original')
%   >> sqw_object = obj.get_sqw('-hisverbatim')
%   >> sqw_object = obj.get_sqw('-nopix')
%   >> sqw_object = obj.get_sqw('-file_backed')
%
% Input:
% --------
%
% infile      If present, the file name, or file identifier of an open file,
%             from which to read data. If absent, the accessor (obj) should be
%             initialized.
%
% Keyword Arguments:
% ------------------
% Optional:  Specify what parts of sqw to read and how to tread output
%
%  '-h'            - header block without instrument and sample information, and
%                  - data block fields: filename, filepath, title, alatt, angdeg,...
%                    uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,img_db_range]
%                    (If the file was written from a structure of type 'b' or 'b+', then
%                    img_db_range does not exist, and the output field will not be created)
%  '-his'          - header block in full i.e. without instrument and sample information, and
%                  - data block fields as for '-h'
%  '-hverbatim'    - Same as '-h' except that the file name as stored in the main_header and
%                    data sections are returned as stored, not constructed from the
%                    value of fopen(fid). This is needed in some applications where
%                    data is written back to the file with a few altered fields.
%  '-hisverbatim'  - Similarly as for '-his'
%  '-nopix'          Pixel information not read (only meaningful for sqw data type 'a')
%  '-legacy'         Return result in legacy format, e.g. 4
%                    fields, namely: main_header, header,
%                    detpar and data
%  '-noupgrade' or - if it is old file format, do not do
%  '-norange'        expensive calculations, necessary for
%                    upgrading file format to recent version
%  '-file_backed'    request the resulting sqw object to be file backed.
%
%
% Default: read all fields of whatever is the sqw data type contained in the file
% and return constructed sqw object
%
% Output:
% --------
%  fully formed sqw object
%
%
% Original author: T.G.Perring
%
opts = horace_binfile_interface.parse_get_sqw_args(varargin{:});


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
    % fill .data
    sqw_skel.data = DnDBase.dnd(sqw_skel.data.metadata,sqw_skel.data.nd_data);
    
    % reconcile detpar and detector arrays - 
    % the save/load cycle for v4 may have detector_arrays occupied but
    % detpar empty.  Alternatively an older saved file may have no detector
    % arrays but info for a single detector in detpar.
    % sanity check detpar and detector_arrays 
    n_runs = numel(sqw_skel.experiment_info.expdata);
    detpar = sqw_skel.detpar;
    if ~isempty(detpar) && ~IX_detector_array.check_detpar_parms(detpar)
        error('faccess_sqw_v4:get_sqw:invalid_argument', ...
              'input detpar has incorrect structure');
    end
    detarrays = sqw_skel.experiment_info.detector_arrays;
    if detarrays.n_runs ~= n_runs
        error('faccess_sqw_v4:get_sqw:invalid_argument', ...
              'input detector arrays have incorrect size');
    end
    % case : no detpar, detector_arrays full
    %      : make detpar an empty detector array
    if isempty(detpar) && detarrays.n_runs > 0
        detpar = detarrays{1}.det_bank(1).detpar;
    % case : detpar is not empty but there is nothing in detector_arrays
    %      : fill detarrays with converted detpar
    elseif ~isempty(detpar) && detarrays.n_runs == 0    
        if ~isempty(detpar) && ~isempty(detpar.group)
            detarr = IX_detector_array(detpar);
        else
            detarr = IX_detector_array();
        end
        detarrays = detarrays.add_copies(detarr,n_runs);
    end
    sqw_skel.experiment_info = Experiment(detarrays, ...
                                          sqw_skel.experiment_info.instruments, ...
                                          sqw_skel.experiment_info.samples,     ...
                                          sqw_skel.experiment_info.expdata);
    sqw_skel.detpar = detpar;
end


if opts.nopix
    sqw_skel = rmfield(sqw_skel,'pix');
else
    if opts.noupgrade || opts.norange
        argi = {'-norange'};
    else
        argi = {};
    end
    if opts.force_pix_location
        if opts.file_backed
            sqw_skel.pix = PixelDataFileBacked(obj,argi{:});
        else
            sqw_skel.pix = PixelDataMemory(obj,argi{:});
        end
    else
        if opts.file_backed
            argi = [argi(:),'-filebacked'];
        end
        sqw_skel.pix = PixelDataBase.create(obj,argi{:});
    end
end

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
    return
elseif opts.head || opts.his
    sqw_object             = sqw_skel;
    sqw_object.num_pixels  = sqw_skel.pix.npix;
else
    sqw_object = sqw(sqw_skel);
end
if nargout > 1
    varargout{1} = obj;
end
