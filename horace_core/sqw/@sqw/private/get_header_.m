function hdr = get_header_(obj)
% return old (legacy) header(s) providing short experiment info

if isempty(obj.experiment_info_)
    hdr = IX_experiment().to_bare_struct();
    hdr.alatt = [];
    hdr.angdeg = [];
    return;
end
hdr = obj.experiment_info_.convert_to_old_headers();
hdr = [hdr{:}];
hdr = rmfield(hdr,{'instrument','sample'});
