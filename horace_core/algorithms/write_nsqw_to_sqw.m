function [img_db_range,pix_data_range]=write_nsqw_to_sqw (infiles, outfile,varargin)
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


% T.G.Perring   27 June 2007
% T.G.Perring   22 March 2013  Modified to enable sqw files with more than one spe file to be combined.
%

accepted_options = {...
    '-parallel'};

if nargin<2
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        'function should have at least 2 input arguments')
end
[ok,mess,combine_in_parallel,argi]...
    = parse_char_options(varargin,accepted_options);
if ~ok
    error('HORACE:write_nsqw_to_sqw:invalid_argument',mess);
end
[pix_data_range,job_disp,jd_initialized]= parse_additional_input4_join_sqw_(argi);

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
% construct target sqw object containing everything except pixel data.
% Instead of PixelData, it will contain information about how to combine
% PixelData
[sqw_mem_part,job_disp] = collect_sqw_metadata(infiles,pix_data_range,job_disp_4head,argi{:});
%
sqw_mem_part.full_filename = outfile;

%

wrtr = sqw_formats_factory.instance().get_pref_access(sqw_mem_part);
%
hor_log_level = get(hor_config,'log_level');
if hor_log_level>-1
    disp(' ')
    disp(['Writing to output file ',outfile,' ...'])
end
% initialize sqw writer algorithm with sqw file to write, containing a normal sqw
% object with pix field containing information about the way to assemble the
% pixels
sqw_mem_part.creation_date  = datetime('now');
wrtr = wrtr.init(sqw_mem_part,outfile);
if combine_in_parallel && jd_initialized
    wrtr = wrtr.put_sqw(job_disp,'-verbatim');
else
    wrtr = wrtr.put_sqw('-verbatim');
end
wrtr.delete();
%
%