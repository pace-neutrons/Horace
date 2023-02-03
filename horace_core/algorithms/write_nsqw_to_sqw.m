function [img_db_range,pix_data_range,wout]=write_nsqw_to_sqw (infiles, outfile,varargin)
% Read a collection of sqw files with a common grid and write to a single sqw file.
%
%   >> write_nsqw_to_sqw (infiles, outfiles,varargin)
%   >>[img_db_range,pix_data_range,wout]  =  write_nsqw_to_sqw (infiles, outfiles,varargin)
%
% Input:
% ------
%   infiles         Cell array or character array of sqw file name(s) of input file(s)
%   outfile         Full name of output sqw file
%
% Optional inputs:
% -allow_equal_headers
%                    -- disables checking input files for absolutely
%                       equal headers. Two file having equal headers is an
%                       error in normal operations so this option used in
%                       tests in case of some specific data modelling.
%                       To learn what headers are considered equal in details
%                       look at  Experiment.combine_experiments method, as
%                       this method performs actual header combining and
%                       checks.
% -parallel          -- combine files using Herbert parallel framework.
%                       this is duplicate for hpc_config option so either
%                       this keyword or hpc_config option or the instance
%                       of the JobDispatcher has to be present to combine
%                       sqw files in  parallel.
% -keep_runid        -- if present, forces routine to keep run-id defined
%                       in the contributing  run-files instead of
%                       setting run-id according to the number of file in
%                       the list of files provided as input to this
%                       algorithm.
%
% JobDispatcherInstance-- the initialized instance of JobDispatcher,
%                       to use in combining sqw files in parallel
%
% pix_data_range     -- [2x9] array of ranges (min/max for q-dE coordinates,
%                       all indexes and signal and error )
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
%  img_db_range   -- the limits of the image coordinates (value for axes.img_range)
%                    defining the grid the pixel data base is binned on
%  pix_data_range -- the actual range of the pixels data, contributing into the
%                    sqw file (useful if input pix_range is not provided)
%  wout           -- filebacked instance of sqw object produced by the
%                    routine and backed by the outfile.


% T.G.Perring   27 June 2007
% T.G.Perring   22 March 2013  Modified to enable sqw files with more than
%               one spe file to be combined.
%

if nargin<2
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        'function should have at least 2 input arguments')
end
accepted_options = {'-parallel','-keep_runid'};
[ok,mess,combine_in_parallel,keep_runid,argi]...
    = parse_char_options(varargin,accepted_options);
if ~ok
    error('HORACE:write_nsqw_to_sqw:invalid_argument',mess);
end
[pix_data_range,job_disp,jd_initialized,argi]= parse_additional_input4_join_sqw_(argi{:});

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
    job_disp = JobDispatcher.instance();
end

% check if writing to output file is possible so that all further
% operations make sense.
[ok,sqw_exist,outfile,err_mess] = check_file_writable(outfile);
if ~ok
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        err_mess);
end
if sqw_exist          % init may want to upgrade the file and this
    delete(outfile);  %  is not the option we want to do here
end

%==========================================================================
% Parallel options.
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
if ~jd_initialized
    job_disp_4head = []; % do not initialize job dispatcher to process headers.
    %  overhead is high and the job is small
else
    job_disp_4head =job_disp;
end
%==========================================================================
%
% construct target sqw object containing everything except pixel data.
% Instead of PixelData, it will contain information about how to combine
% PixelData
if keep_runid
    argi = ['-keep_runid';argi(:)];
end
[sqw_mem_part,~,job_disp] = collect_sqw_metadata(infiles,pix_data_range,job_disp_4head,argi{:});
if ~isempty(job_disp)
    job_disp.finalize_all();
end
sqw_mem_part.full_filename = outfile;
sqw_mem_part.creation_date  = datetime('now');
%
[hor_log_level,use_mex] = config_store.instance().get_value(hor_config,'log_level','use_mex');
if hor_log_level>-1
    disp(' ')
    disp(['Writing to output file ',outfile,' ...'])
end
% initialize sqw writer algorithm with sqw file to write, containing a normal sqw
% object with pix field containing information about the way to assemble the
% pixels


page_op         = PageOp_join_sqw;
page_op.outfile = outfile;
%
if keep_runid
    run_id = [];
else
    run_id = sqw_mem_part.runid_map.keys();
    run_id = [run_id{:}];
end
hpc = hpc_config;
use_mex = use_mex && strncmp(hpc.combine_sqw_using,'mex',3);
[page_op,wout]  = page_op.init(sqw_mem_part,run_id,use_mex);
% TODO: Re #1320 do not load result in memory and do not initilize
% filebacked operations if it is not requested
wout            = sqw.apply_op(wout,page_op);

% Set up output averages
img_db_range   = sqw_mem_part.data.img_range;
pix_data_range = sqw_mem_part.pix.data_range;
%
%