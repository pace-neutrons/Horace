function exp_info = build_from_binfile_headers_(header)
% restore basic experiment info from old style headers,
% stored on hdd in binary format
%

n_header = numel(header);
exper = repmat(IX_experiment,1,n_header);
samp = cell(n_header,1);
inst = unique_objects_container('type','{}','baseclass','IX_inst'); %cell(n_header,1);
for i=1:n_header
    if iscell(header)
        [exper(i),alatt,angdeg] = IX_experiment.build_from_binfile_header(header{i});
    else
        [exper(i),alatt,angdeg] = IX_experiment.build_from_binfile_header(header(i));
    end
    samp{i} = IX_samp('',alatt,angdeg);
    inst{i} = IX_null_inst();
end
%
exp_info = Experiment([],inst,samp,exper);
%