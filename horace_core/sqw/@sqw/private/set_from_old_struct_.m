function obj = set_from_old_struct_(obj,S)
% restore object from the old structure, which describes the
% previous version(s) of the object.
%
% The method is called by loadobj in the case if the input
% structure does not contain version or the version, stored
% in the structure does not correspond to the current version
%
% Input:
% ------
%   S       An instance of this object or structure
% By default, this function interfaces the default from_bare_struct
% method, but when the old structure substantially differs from
% the modern structure, this method needs the specific overloading
% to allow loadobj to recover new structure from an old structure.
%
if ~isfield(S,'version') || S.version<4
    % previous version did not store any version data
    if numel(S)>1
        tmp = sqw();
        obj = repmat(tmp, size(S));
    end
    for i = 1:numel(S)
        ss =S(i);
        if isfield(ss,'main_header')
            ss.main_header = main_header_cl(ss.main_header);
        end
        if isfield(ss,'header')
            if isa(ss.header,'Experiment')
                ss.experiment_info = ss.header;
            else
                ss.experiment_info = Experiment(ss.header);
            end
            ss = rmfield(ss,'header');
        end
        if isfield(ss,'experiment_info') && isstruct(ss.experiment_info)
            ss.experiment_info = Experiment.loadobj(ss.experiment_info);
        end

        % the detpar value will be put in further down in from_bare_struct.
        % NB reminder that this will require experiment_info having an empty
        % detector_arrays rather than being preconstructed
        if isfield(ss,'data_')
            ss.data = ss.data_;
            ss = rmfield(ss,'data_');
        end
        if isfield(ss,'runid_map')
            ss.experiment_info.runid_map = ss.runid_map;
            ss = rmfield(ss,'runid_map');
        end
        if isfield(ss,'data')
            if isstruct(ss.data)
                ss.data = data_sqw_dnd.loadobj(ss.data);
            end
            if isa(ss.data,'data_sqw_dnd')
                if ss.experiment_info.samples.n_runs == 0
                    sam = IX_samp('alatt',ss.data.alatt,'angdeg',ss.data.angdeg);
                    ss.experiment_info.samples{1} = sam;
                    if ss.experiment_info.instruments.n_runs == 0
                        ss.experiment_info.instruments{1} = IX_null_inst();
                    end
                end
                hav = header_average(ss.experiment_info);
                proj = ss.data.proj;
                if isempty(hav.alatt) % no actual header, happens in old test files
                    exper = IX_experiment('','','alatt',proj.alatt,'angdeg',proj.angdeg);
                    if isempty(ss.data.pix)
                        exper.run_id = 1;
                    else
                        exper.run_id = unique(ss.data.pix.run_idx);
                        if numel(exper.run_id)>1
                            error('HORACE:sqw:invalid_argumet', ...
                                'the sqw object without header refers to more then 1 run according to pixels run_id')
                        end
                    end
                    ss.experiment_info.expdata = exper;
                    ss.main_header.nfiles = 1;
                end
                ax   = ss.data.axes;
                if isa(ss.data.pix,'PixelDataBase')
                    ss.pix = PixelDataMemory(ss.data.pix.data);
                end
                ss.data = DnDBase.dnd(ax,proj,ss.data.s,ss.data.e,ss.data.npix);
            end % data_sqw_dnd present
        else % data field absent
            error('HORACE:sqw:invalid_argument', ...
                'Can not load old sqw object which does not contain "data" field')
        end
        % check legacy alignment and convert it into modern alignment
        hav= ss.experiment_info.header_average();
        al_info = dnd_data_alignment(ss.data,hav);
        if ~isempty(al_info) && isfield(ss,'pix')
            ss.pix.alignment_matr = al_info.rotmat;
        end

        % guard against old data formats, which may or may not contain
        % runid map and the map may or may not correspond to
        % pixel_id
        if ~ss.main_header.creation_date_defined
            if isfield(ss,'data') && ...
                    ss.pix.num_pixels>0 && ~ss.pix.is_filebacked()
                ss = update_pixels_run_id(ss);
            end
        end
        if isfield(ss,'detpar')
            ss.experiment_info.detector_arrays =  ...
                horace_binfile_interface.convert_old_det_forms( ...
                ss.detpar,ss.experiment_info.n_runs);
        end

        obj(i) = obj(i).from_bare_struct(ss);
    end
    return
end
if isfield(S,'array_dat')
    obj = obj.from_bare_struct(S.array_dat);
else
    obj = obj.from_bare_struct(S);
end

if ~isfield(S,'version')
    S.version = 0;
end
%
if S.version == 4
    % may contain legacy alignment not stored in projection. Deal with this here
    hav  = obj.experiment_info.header_average();
    al_info = dnd_data_alignment(obj.data,hav);
    if ~isempty(al_info)
        obj.pix.alignment_matr = al_info.rotmat;
    end
end
if S.version < 6
    % may contain detpar stored in their own field and not present within
    % the experiment_info
    if obj.experiment_info.detector_arrays.n_objects == 0
        obj.detpar = S.detpar; % use setter to deal with possible presence
        % of old array format. Setter checks for that and converts appropriately
    end
end
