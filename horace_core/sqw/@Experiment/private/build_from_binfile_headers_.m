function exp_info = build_from_binfile_headers_(header)
% restore basic experiment info from old style headers,
% stored on hdd in binary format
%

n_header = numel(header);
exper = repmat(IX_experiment,1,n_header);
samp = unique_references_container('IX_samp'); %cell(n_header,1);
inst = unique_references_container('IX_inst'); %cell(n_header,1);
%detc = unique_references_container('IX_detector_array'); 
for i=1:n_header
    if iscell(header)
        hdr = header{i};
    else
        hdr = header(i);
    end
    [exper(i),alatt,angdeg] = IX_experiment.build_from_binfile_header(hdr);
    
    if ~isfield(hdr,'instrument') || isempty(hdr.instrument)
        inst{i} = IX_null_inst();
    else
        inst{i} = hdr.instrument;
    end
    if ~isfield(hdr,'sample') || isempty(hdr.sample)
        samp{i} = IX_samp('',alatt,angdeg);        
    else
        samp{i} = hdr.sample;
    end
end
%
% the detc variable creates the container but it will be
% empty until subsequent code populates it from detpar
%detc = detc.add(repmat(IX_detector_array(),1,n_header));
% the detectors in exp_info will be empty until populated later
% if we put detc into the constructor, it would fail with incorrect number
% (0) of detector arrays

exp_info = Experiment([],inst,samp,exper);
%