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
%   S       An instance of this object or struct
% By default, this function interfaces the default from_bare_struct
% method, but when the old strucure substantially differs from
% the modern structure, this method needs the specific overloading
% to allow loadob to recover new structure from an old structure.
%
if ~isfield(S,'version')
    % previous version did not store any version data
    if numel(S)>1
        tmp = sqw();
        obj = repmat(tmp, size(S));
    end
    for i = 1:numel(S)
        ss =S(i);
        if isfield(ss,'header')
            if isa(ss.header,'Experiment')
                ss.experiment_info = ss.header;
            else
                ss.experiment_info = Experiment(ss.header);
            end
            ss = rmfield(ss,'header');
        end
        if isfield(ss,'data_')
            ss.data = ss.data_;
            ss = rmfield(ss,'data_');
        end

        obj(i) = sqw(ss);
        if isempty(obj(i).runid_map)
            obj(i).runid_map = recalculate_runid_map_(obj(i).experiment_info);
        end
        % guard against old data formats:
        if ~isempty(obj(i).data.pix) && obj(i).data.pix.num_pixels>0 && ...
                ~obj(i).data.pix.is_filebacked()
            pix_id = unique(obj(i).data.pix.run_idx);
            kind = obj(i).runid_map.keys;
            kind = [kind{:}];
            if ~all(ismember(pix_id,kind)) % pixel id-s were recalculated
                id = 1:numel(kind);
                obj(i).runid_map = containers.Map(id,id);
            end
        end
        exp_data = obj(i).experiment_info.expdata;
        ids = exp_data.get_run_ids();
        if any(isnan(ids)) % set data headers run_ids from run_id map
            % as the run_ids have not been stored with IX_experiment before
            ids = obj(i).runid_map.keys();
            ids = [ids{:}];
            for j =1:numel(ids)
                exp_data(j).run_id = ids(j);
            end
            obj(i).experiment_info.expdata = exp_data;
        end
    end
    return
end
if isfield(S,'array_dat')
    obj = obj.from_bare_struct(S.array_dat);
else
    obj = obj.from_bare_struct(S);
end
for i=1:numel(obj)
    obj(i).runid_map = recalculate_runid_map_(obj(i).experiment_info.expdata);
end
