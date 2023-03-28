function exp_info = build_from_binfile_headers_(header)
% restore basic experiment info from old style headers,
% stored on hdd in binary format
%

n_header = numel(header);
exper = repmat(IX_experiment,1,n_header);
%samp = cell(n_header,1);
samp = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER','IX_samp'); %cell(n_header,1);
inst = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst'); %cell(n_header,1);
detc = unique_references_container('GLOBAL_NAME_DETECTORS_CONTAINER','IX_detector_array'); %cell(n_header,1);
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
% the detector arg creates the container but it will be
% empty until subsequent code populates it from detpar
exp_info = Experiment(detc,inst,samp,exper);
%