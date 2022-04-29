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
        if isfield(ss,'runid_map')
            ss.experiment_info.runid_map = ss.runid_map;
            ss = rmfield(ss,'runid_map');
        end
        % guard against old data formats, which may or may not contain 
        % runid map and the map may or may not correspond to 
        % pixel_id
        if isfield(ss,'data') && isa(ss.data,'data_sqw_dnd') && ...
           ss.data.pix.num_pixels>0 && ~ss.data.pix.is_filebacked()
            % check consistency between pixel run_id and header runids. 
            % this is not always possible to achieve, but is pissible in
            % assumption that pixel-ids were recalculated from 1 to
            % n-headers
            pix_runid = unique(ss.data.pix.run_idx);
        
            header_run_id = ss.experiment_info.runid_map.keys();
            header_run_id = [header_run_id{:}];
  
            if ~all(ismember(pix_runid,header_run_id))                 
                id = 1:ss.experiment_info.n_runs;
                ss.experiment_info.runid_map = id;
            end
            % old data format where headers are stored all together including 
            % the headers, which do not contributed into the pixels.
            % retrieve only contributed headers
            if numel(pix_runid)<ss.experiment_info.n_runs
                % can do it in assump
                ss.experiment_info = ss.experiment_info.get_subobj(pix_runid);
                ss.main_header.nfiles = ss.experiment_info.n_runs;
            end
        end        

        obj(i) = sqw(ss);
    end
    return
end
if isfield(S,'array_dat')
    obj = obj.from_bare_struct(S.array_dat);
else
    obj = obj.from_bare_struct(S);
end
