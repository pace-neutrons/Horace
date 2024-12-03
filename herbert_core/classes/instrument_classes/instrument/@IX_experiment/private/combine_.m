function obj = combine_(obj,exper_cellarray,keep_runid,this_runid_map)
% COMBINE_ : properly combines input IX_experiment array with elements
% contained in exper_cellarray, ignoring possible duplicates
% Inputs:
% obj             -- sinle instance or array of IX_experiment objects
% exper_cellarray -- exper_cellarray cellarray containing
%                     IX_experiments arrays
% keep_runid      -- boolean, which includes true if run_id-s
%                    stored in IX_experiment data should be
%                    kept or final obj run_id should be
%                    recalculated.
% WARNING:        -- run_id(s) modified if keep_runid == false
%                    must be synchronized with run_id(s) stored
%                    in pixels, which means that keep_runid ==
%                    false could be used mainly in tests
% Returns:
% obj             -- resulting array, containing unique
%                    instances of IX_experiment classes with
%                    all non-unique IX_experiments excluded.
if isempty(exper_cellarray)
    if ~keep_runid
        obj = recalc_runid(obj);
    end
    return;
end
if nargin<4
    this_runid_map = obj.get_runid_map();
end
if isa(exper_cellarray{1},'Experiment')
    res_data = cellfun(@(x)[{x.expdata},{x.runid_map}],exper_cellarray);
    exper_cellarray= res_data(1,:);
    runid_map      = res_data(2,:);
else
    runid_map      = cellfun(@(x)(x.get_runid_map),exper_cellarray,'UniformOutput','false');
end

n_exper_to_add = numel(exper_cellarray);
add_runs  = cell(1,n_exper_to_add );
add_runid = cell(1,n_exper_to_add );
n_addruns = 0;
for i=1:n_exper_to_add
    add_map = runid_map{i};
    keys = add_map.keys;
    for j=1:exper_cellarray{i}.n_runs
        if this_runid_map.isKey
    end
end
expinfo(ic)= exper_cellarray{i}.expdata(j);
if ~keep_runid
    expinfo(ic).run_id = ic;
end




expinfo(1).emode ~= expinfo(ic).emode

neq_hashes{ic} = expinfo(ic).get_neq_hash();
if ismember(neq_hashes{ic},neq_hashes(1:ic-1))
    error('HORACE:Experiment:runtime_error',[...
        'filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data inputs\n' ...
        'File: N%d, contributed run %d differs from the first run '],i,j);
end



    function obj = recalc_runid(obj)
        for i=1:numel(obj)
            obj(i).run_id = i;
        end
    end
