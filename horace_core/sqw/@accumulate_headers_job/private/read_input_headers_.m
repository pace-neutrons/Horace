function [main_header,exp_info,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
    read_input_headers_(infiles)
% Read information necessary for combining various tmp files together

% Read header information:
if ~iscell(infiles)
    infiles = {infiles};
end
nfiles = numel(infiles);

main_header=cell(nfiles,1);
exp_info=cell(nfiles,1);
datahdr=cell(nfiles,1);
%pos_datastart=zeros(nfiles,1);
pos_npixstart=zeros(nfiles,1);
pos_pixstart=zeros(nfiles,1);
npixtot=zeros(nfiles,1);

mess_completion(nfiles,5,0.1);   % initialise completion message reporting

ldrs = sqw_formats_factory.instance().get_loader(infiles);
for i=1:nfiles
    data_type = ldrs{i}.data_type;
    if ~strcmpi(data_type,'a'); error('WRITE_NSQW_TO_SQW:invalid_argument',...
            ['No pixel information in ',infiles{i}]); end
    main_header{i} = ldrs{i}.get_main_header();
    exp_info{i}    = ldrs{i}.get_exp_info('-all');
    datahdr{i}     = ldrs{i}.get_dnd_metadata();
    det_tmp        = ldrs{i}.get_detpar();
    if (~isempty(det_tmp)                                 && ...
            IX_detector_array.check_detpar_parms(det_tmp) && ...
            exp_info{i}.detector_arrays.n_runs == 0            )

        detector = IX_detector_array(det_tmp);
        exp_info{i}.detector_arrays = exp_info{i}.detector_arrays.add(detector);
    end
    if i==1
        det=det_tmp;    % store the detector information for the first file
    else
        det_tmp.filename = det.filename;
        det_tmp.filepath = det.filepath;
    end
    clear det_tmp       % save memory on what could be a large variable

    %pos_datastart(i)=ldrs{i}.data_position;  % start of data block
    pos_npixstart(i)=ldrs{i}.npix_position;  % start of npix field
    pos_pixstart(i) =ldrs{i}.pix_position;   % start of pix field
    npixtot(i)      =ldrs{i}.npixels;
    mess_completion(i) % did not have terminating semi-colon, keeping it that way
end
mess_completion() % did not have terminating semi-colon, keeping it that way
