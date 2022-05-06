function [img_db_range,pix_range]=write_nsqw_to_sqw (infiles, outfile,varargin)
% Read a collection of sqw files with a common grid and write to a single sqw file.
%
%   >> write_nsqw_to_sqw (infiles, outfiles,varargin)
%
% Input:
% ------
%   infiles         Cell array or character array of sqw file name(s) of input file(s)
%   outfile         Full name of output sqw file
%
% Optional inputs:
% -allow_equal_headers -- disables checking input files for absolutely
%                       equal headers. Two file having equal headers is an error
%                       in normal operations so this option  used in
%                       tests or when equal zones are combined.
% -drop_subzones_headers -- in combine_equivalent_zones all sub-files are cut from
%                       single sqw file and may be divided into sub-zones.
%                       this option used to avoid duplicating headers
%                       from the same zone
% -parallel           -- combine files using Herbert parallel framework.
%                       this is duplicate for hpc_config option (currently
%                       missing) so either this keyword or hpc_config
%                       option or the instance of the JobDispatcher has to
%                       be present to combine sqw files in  parallel.
% -keep_runid         -- if present, forces routine to keep run-id specific
%                       defined in the contributing run-files instead of
%                       generating run-id on the basis of the data, stored
%                       in the runfiles
%
% JobDispatcherInstance-- the initialized instance of JobDispatcher,
%                       to use in combining sqw files in parallel
%
% pix_range          -- [2x4] array of ranges (min/max q-dE coordinates values)
%                       of all pixels, from all contributing files combined
%                       together. The value is stored in the file
% WARNING:
%     If pix_range is not provided the pix_range in the file will be
%     calculated from the pix ranges from all input files and stored
%     together with pixels.
%     If it is provided, the provided value will be stored as the pixels
%     range.  No checks are performed, so this range has to be
%     correct to avoid very difficult to trace errors.
%
% Output:
% -------
%  img_db_range       -- the limits of the internal coordinates contained in
%                     the combined fil
%  pix_range       -- the actual range of the pixels, contributing into the
%                     sqw file (useful if input pix_range is not provided)


% T.G.Perring   27 June 2007
% T.G.Perring   22 March 2013  Modified to enable sqw files with more than one spe file to be combined.
%

accepted_options = {'-allow_equal_headers','-keep_runid',...
    '-drop_subzones_headers','-parallel'};

if nargin<2
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        'function should have at least 2 input arguments')
end
[ok,mess,allow_equal_headers,keep_runid,drop_subzone_headers,combine_in_parallel,argi]...
    = parse_char_options(varargin,accepted_options);
if ~ok
    error('HORACE:write_nsqw_to_sqw:invalid_argument',mess);
end
[pix_range,job_disp,jd_initialized]= parse_additional_input(argi);

persistent old_matlab;
if isempty(old_matlab)
    old_matlab = verLessThan('matlab', '8.1');
end

combine_mode = config_store.instance().get_value('hpc_config','combine_sqw_using');
if isempty(job_disp)
    if strcmp(combine_mode,'mpi_code') || combine_in_parallel
        combine_in_parallel = true;
    else
        combine_in_parallel = false;
    end
else
    combine_in_parallel = true;
end

if combine_in_parallel && isempty(job_disp) % define name of new parallel job and initiate it.
    [~,fn] = fileparts(outfile);
    if numel(fn) > 8
        fn = fn(1:8);
    end
    job_name = ['job_nsqw2sqw_',fn];
    %
    job_disp = JobDispatcher(job_name);
end


hor_log_level=config_store.instance().get_value('herbert_config','log_level');

% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------


% Check that the input files all exist and give warning if the output files overwrite the input files.
% ----------------------------------------------------------------------------------------------------
% Convert to cell array of strings if necessary
if ~iscellstr(infiles)
    infiles=cellstr(infiles);
end

% Check input files exist
nfiles=length(infiles);
for i=1:nfiles
    if exist(infiles{i},'file')~=2
        error('HORACE:write_nsqw_to_sqw:invalid_argument',...
            'Can not find file: %s',infiles{i})
    end
end

% *** Check output file can be opened
% *** Check that output file and input files do not coincide
% *** Check do not repeat an input file name
% *** Check they are all sqw files


% Read header information from files, and check consistency
% ---------------------------------------------------------
% At present we require that all detector info is the same for all files, and each input file contains only one spe file
if hor_log_level>-1
    disp(' ')
    disp('Reading header(s) of input file(s) and checking consistency...')
end

%[main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs]
[~,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
    accumulate_headers_job.read_input_headers(infiles);
if all(all(pix_range == PixelData.EMPTY_RANGE_))
    pix_range = pix_combine_info.recalc_pix_range_from_loaders(ldrs);
end

% Check consistency:
% At present, we insist that the contributing spe data are distinct in that:
%   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
%   - emode, lattice parameters, u, v, sample must be the same for all spe data input
% We must have same data information for alatt, angdeg, uoffset, u_to_rlu, ulen, pax, iint, p
% This guarantees that the pixels are independent (the data may be the same if an spe file name is repeated, but
% it is assigned a different Q, and is in the spirit of independence)
[header_combined,nspe] = Experiment.combine_experiments(header,allow_equal_headers,drop_subzone_headers);
%[header_combined,nspe] = sqw_header.header_combine(header,allow_equal_headers,drop_subzone_headers);


img_db_range=datahdr{1}.img_range;
for i=2:nfiles
    img_db_range=[min(img_db_range(1,:),datahdr{i}.img_range(1,:));max(img_db_range(2,:),datahdr{i}.img_range(2,:))];
end



%  Build combined header
if drop_subzone_headers
    nfiles_2keep = nspe>0;
    nspec = nspe(nfiles_2keep);
    nfiles_tot=sum(nspec);
else
    nfiles_tot=sum(nspe);
end
main_header_combined.filename='';
main_header_combined.filepath='';
main_header_combined.title='';
main_header_combined.nfiles=nfiles_tot;

sqw_data = data_sqw_dnd(datahdr{1});
sqw_data.filename=main_header_combined.filename;
sqw_data.filepath=main_header_combined.filepath;
sqw_data.title=main_header_combined.title;
% img_db_range at this stage is equal to pix_range + halo ~ eps, if pix_range was
% estimated or input_pix_range if it has been provided
sqw_data.img_range=img_db_range;

% Now read in binning information
% ---------------------------------
% We did not read in the arrays s, e, npix from the files because if have a 50^4 grid then the size of the three
% arrays is is total 24*50^4 bytes = 150MB. Firstly, we cannot afford to read all of these arrays as it would
% require too much RAM (30GB if 200 spe files); also if we just want to check the consistency of the header information
% in the files first we do not want to spend lots of time reading and accumulating the s,e,npix arrays. We can do
% that now, as we have checked the consistency.
if hor_log_level>-1
    disp(' ')
    disp('Reading and accumulating binning information of input file(s)...')
end

if combine_in_parallel
    %TODO:  check config for appropriate ways of combining the tmp and what
    %to do with cluster
    comb_using = config_store.instance().get_value('hpc_config','combine_sqw_using');
    if strcmp(comb_using,'mpi_code') % keep cluster running for combining procedure
        keep_workers_running = true;
    else
        keep_workers_running = false;
    end
    [common_par,loop_par] = accumulate_headers_job.pack_job_pars(ldrs);
    if jd_initialized
        [outputs,n_failed,~,job_disp]=job_disp.restart_job(...
            'accumulate_headers_job',common_par,loop_par,true,keep_workers_running );
        n_workers = job_disp.cluster.n_workers;
    else
        n_workers = config_store.instance().get_value('hpc_config','parallel_workers_number');
        [outputs,n_failed,~,job_disp]=job_disp.start_job(...
            'accumulate_headers_job',common_par,loop_par,true,n_workers,keep_workers_running );
    end
    %
    if n_failed == 0
        s_accum = outputs{1}.s;
        e_accum = outputs{1}.e;
        npix_accum = outputs{1}.npix;
    else
        job_disp.display_fail_job_results(outputs,n_failed,n_workers, ...
            'HORACE:write_nsqw_to_sqw:runtime_error');
    end
    
    
else
    % read arrays and accumulate headers directly
    [s_accum,e_accum,npix_accum] = accumulate_headers_job.accumulate_headers(ldrs);
end
[s_accum,e_accum] = normalize_signal(s_accum,e_accum,npix_accum);
%
sqw_data.s=s_accum;
sqw_data.e=e_accum;
sqw_data.npix=uint64(npix_accum);

clear nopix
[ok,sqw_exist,outfile,err_mess] = check_file_writable(outfile);
if ~ok
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        err_mess);
end
if sqw_exist          % init may want to upgrade the file and this
    delete(outfile);  %  is not the option we want to do here
end


% Write to output file
% ---------------------------
if hor_log_level>-1
    disp(' ')
    disp(['Writing to output file ',outfile,' ...'])
end
if drop_subzone_headers || keep_runid
    run_label = 'nochange';
else
    run_label=cumsum(nspe(1:end));
end
% if old_matlab
%     npix_cumsum = cumsum(double(sqw_data.npix(:)));
% else
%     npix_cumsum = cumsum(sqw_data.npix(:));
% end
%
% instead of the real pixels to place in target sqw file, place in pix field the
% information about the way to get the contributing pixels
sqw_data.pix = pix_combine_info(infiles,numel(sqw_data.npix),pos_npixstart,pos_pixstart,npixtot,run_label);
sqw_data.pix.pix_range = pix_range;

[fp,fn,fe] = fileparts(outfile);
main_header_combined.filename = [fn,fe];
main_header_combined.filepath = [fp,filesep];
%
data_sum= struct('main_header',main_header_combined,'experiment_info',[],'detpar',det);
data_sum.data = sqw_data;
data_sum.experiment_info = header_combined;
% TODO: this will go, as header combined contains runid_map
data_sum.runid_map = header_combined.runid_map;

ds = sqw(data_sum);
wrtr = sqw_formats_factory.instance().get_pref_access(ds);

% initialize sqw writer algorithm with sqw file to write, containing a normal sqw
% object with pix field containing information about the way to assemble the
% pixels
wrtr = wrtr.init(ds,outfile);
if combine_in_parallel
    wrtr = wrtr.put_sqw(job_disp);
else
    wrtr = wrtr.put_sqw();
end
wrtr.delete();
%
%
function [pix_range,job_disp,jd_initialized]= parse_additional_input(argi)
% parse input to extract pixel range and initialized job dispatcher if any
% of them provided as input arguments
%
pix_range = PixelData.EMPTY_RANGE_;
job_disp = [];
jd_initialized = false;
%
if isempty(argi)
    return;
end

is_jd = cellfun(@(x)(isa(x,'JobDispatcher')),argi,'UniformOutput',true);
if any(is_jd)
    job_disp = argi(is_jd);
    if numel(job_disp) >1
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
            'only one instance of JobDispatcher can be provided as input');
    else
        job_disp  = job_disp{1};
    end
    if ~job_disp.is_initialized
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
            ['Only initialized JobDispatcher is currently supported',...
            ' as input for write_nsqw_to_sqw.',...
            ' Use "parallel" option to combine files in parallel']);
    end
    jd_initialized = true;
    argi = argi(~is_jd);
end
%
if isempty(argi)
    return;
end
%
is_range = cellfun(@(x)(all(size(x) == [2,4])),argi,'UniformOutput',true);
if ~any(is_range)
    return;
end
if sum(is_range) > 1
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        ['More then one variable in input arguments is interpreted as range.',...
        ' This is not currently supported'])
end
pix_range  = argi{is_range};
