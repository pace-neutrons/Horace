function [img_db_range,data_range]=write_nsqw_to_sqw (infiles, outfile,varargin)
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
%                    defining the grit the pixel data base is binned on
%  pix_data_range -- the actual range of the pixels data, contributing into the
%                    sqw file (useful if input pix_range is not provided)


% T.G.Perring   27 June 2007
% T.G.Perring   22 March 2013  Modified to enable sqw files with more than one spe file to be combined.
%

accepted_options = {'-allow_equal_headers','-keep_runid',...
    '-parallel'};

if nargin<2
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        'function should have at least 2 input arguments')
end
[ok,mess,allow_equal_headers,keep_runid,combine_in_parallel,argi]...
    = parse_char_options(varargin,accepted_options);
if ~ok
    error('HORACE:write_nsqw_to_sqw:invalid_argument',mess);
end
[data_range,job_disp,jd_initialized]= parse_additional_input(argi);

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

if ~jd_initialized
    job_disp_4head = []; % do not initialize job dispatcher to process headers.
    %  overhead is high and the job is small
else
    job_disp_4head =job_disp;
end
% construct target sqw object containing everything except pixel data.
% Instead of PixelData, it will contain information about how to combine
% PixelData
[sqw_struc_sum,img_db_range,data_range,job_disp_4head]=get_pix_comb_info_(infiles,data_range,job_disp_4head, ...
    allow_equal_headers,keep_runid);
if ~isempty(job_disp_4head)
    job_disp = job_disp_4head;
end
%
%
%
sqw_struc_sum.main_header.full_filename = outfile;
sqw_struc_sum.pix.full_filename = outfile;
%
ds = sqw(sqw_struc_sum);
wrtr = sqw_formats_factory.instance().get_pref_access(ds);
%
hor_log_level = get(hor_config,'log_level');
if hor_log_level>-1
    disp(' ')
    disp(['Writing to output file ',outfile,' ...'])
end
% initialize sqw writer algorithm with sqw file to write, containing a normal sqw
% object with pix field containing information about the way to assemble the
% pixels
ds.creation_date  = datetime('now');
ds.full_filename = outfile;
wrtr = wrtr.init(ds,outfile);
if combine_in_parallel
    wrtr = wrtr.put_sqw(job_disp,'-verbatim');
else
    wrtr = wrtr.put_sqw('-verbatim');
end
wrtr.delete();
%
%
function [data_range,job_disp,jd_initialized]= parse_additional_input(argi)
% parse input to extract pixel range and initialized job dispatcher if any
% of them provided as input arguments
%
data_range = PixelDataBase.EMPTY_RANGE;
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
is_range = cellfun(@(x)(isequal(size(x),[2,9])),argi,'UniformOutput',true);
if ~any(is_range)
    return;
end
if sum(is_range) > 1
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        ['More then one variable in input arguments is interpreted as range.',...
        ' This is not currently supported'])
end
data_range  = argi{is_range};
