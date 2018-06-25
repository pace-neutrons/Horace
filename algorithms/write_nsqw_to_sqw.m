function write_nsqw_to_sqw (infiles, outfile,varargin)
% Read a collection of sqw files with a common grid and write to a single sqw file.
%
%   >> write_nsqw_to_sqw (infiles, outfiles,varargin)
%
% Input:
% ------
%   infiles         Cell array or character array of sqw file name(s) of input file(s)
%   outfile         Full name of output sqw file
%   varargin        If present can be the keyword one or all of the keywords
%                   or the instance of initialized JobDispatcher, running
%                   parallel framework or non-initialized JobDispatcher to
%                   combine sqw tiles in parallel
%Optional inputs:
% allow_equal_headers -- disables checking input files for absolutely
%                       equal headers. Two file having equal headers is an error
%                       in normal operations so this option  used in
%                       tests or when equal zones are combined.
% drop_subzones_headers -- in combine_equivalent_zones all subfiles are cut from
%                       single sqw file and may be divided into subzones.
%                       this option used to avoid duplicating headers
%                       from the same zone
% parallel           -- combine files using Herbert parallel framework.
%                       this is duplicate for hpc_config option (currently
%                       missing) so either this keyword or hpc_config
%                       option or the instance of the JobDispatcher has to
%                       be present to combine sqw files in  parallel.
% aJobDispatcherInstance-- the instance of JobDispatcher, to use in
%                       combining sqw files in parallel
%
% Output:
% -------
%   <no output arguments>


% T.G.Perring   27 June 2007
% T.G.Perring   22 March 2013  Modified to enable sqw files with more than one spe file to be combined.
%
% $Revision$ ($Date$)
accepted_options = {'allow_equal_headers','drop_subzones_headers','parallel'};

persistent old_matlab;
if isempty(old_matlab)
    old_matlab = verLessThan('matlab', '8.1');
end
if nargin<2
    error('WRITE_NSQW_TO_SQW:invalid_argument',...
        'function should have at least 2 input arguments')
end

[ok,mess,drop_subzone_headers,allow_equal_headers,combine_in_parallel,argi]...
    = parse_char_options(varargin,accepted_options);
if ~ok
    error('WRITE_NSQW_TO_SQW:invalid_argument',mess);
end
if ~isempty(argi)
    is_jd = cellfun(@(x)(isa(x,'JobDispatcher')),argi,'UniformOutput',true);
    if any(is_jd)
        job_disp = argi(is_jd);
        if numel(job_disp) >1
            error('WRITE_NSQW_TO_SQW:invalid_argument',...
                'only one instance of JobDispatcher can be provided as input');
        else
            job_disp  = job_disp{1};
        end
        argi = argi(~is_jd);
        if ~job_disp.is_initialized
            error('WRITE_NSQW_TO_SQW:invalid_argument',...
                'Only initialized JobDispatcher is currently supported as input for write_nsqw_to_sqw');
        end
    else
        job_disp = [];
    end
else
    job_disp = [];
end


hor_log_level=config_store.instance().get_value('hor_config','log_level');

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
        error('WRITE_NSQW_TO_SQW:invalid_argument',...
            ['File ',infiles{i},' not found'])
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


[main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
    read_input_headers(infiles);

% Check consistency:
% At present, we insist that the contributing spe data are distinct in that:
%   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
%   - emode, lattice parameters, u, v, sample must be the same for all spe data input
% We must have same data information for alatt, angdeg, uoffset, u_to_rlu, ulen, pax, iint, p
% This guarantees that the pixels are independent (the data may be the same if an spe file name is repeated, but
% it is assigned a different Q, and is in the spirit of independence)
[header_combined,nspe] = sqw_header.header_combine(header,allow_equal_headers,drop_subzone_headers);


if numel(datahdr) > 1
    sqw_header.check_headers_equal(datahdr{1},datahdr(2:end));
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

sqw_data = data_sqw_dnd();
sqw_data.filename=main_header_combined.filename;
sqw_data.filepath=main_header_combined.filepath;
sqw_data.title=main_header_combined.title;
sqw_data.alatt=datahdr{1}.alatt;
sqw_data.angdeg=datahdr{1}.angdeg;
sqw_data.uoffset=datahdr{1}.uoffset;
sqw_data.u_to_rlu=datahdr{1}.u_to_rlu;
sqw_data.ulen=datahdr{1}.ulen;
sqw_data.ulabel=datahdr{1}.ulabel;
sqw_data.iax=datahdr{1}.iax;
sqw_data.iint=datahdr{1}.iint;
sqw_data.pax=datahdr{1}.pax;
sqw_data.p=datahdr{1}.p;
sqw_data.dax=datahdr{1}.dax;    % take the display axes from first file, for sake of choosing something

sqw_data.urange=datahdr{1}.urange;
for i=2:nfiles
    sqw_data.urange=[min(sqw_data.urange(1,:),datahdr{i}.urange(1,:));max(sqw_data.urange(2,:),datahdr{i}.urange(2,:))];
end


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

% Read data:
mess_completion(nfiles,5,0.1);   % initialise completion message reporting
for i=1:nfiles
    % get signal error and npix information
    bindata = ldrs{i}.get_se_npix();
    if i==1
        s_accum = (bindata.s).*(bindata.npix);
        e_accum = (bindata.e).*(bindata.npix).^2;
        npix_accum = bindata.npix;
    else
        s_accum = s_accum + (bindata.s).*(bindata.npix);
        e_accum = e_accum + (bindata.e).*(bindata.npix).^2;
        npix_accum = npix_accum + bindata.npix;
    end
    clear bindata
    mess_completion(i)
end

s_accum = s_accum ./ npix_accum;
e_accum = e_accum ./ npix_accum.^2;
nopix=(npix_accum==0);
s_accum(nopix)=0;
e_accum(nopix)=0;
%
sqw_data.s=s_accum;
sqw_data.e=e_accum;
sqw_data.npix=uint64(npix_accum);

clear nopix
mess_completion


% Write to output file
% ---------------------------
if hor_log_level>-1
    disp(' ')
    disp(['Writing to output file ',outfile,' ...'])
end
if drop_subzone_headers
    run_label = 'nochange';
else
    run_label=cumsum([0;nspe(1:end-1)]);
end
if old_matlab
    npix_cumsum = cumsum(double(sqw_data.npix(:)));
else
    npix_cumsum = cumsum(sqw_data.npix(:));
end
sqw_data.pix = pix_combine_info(infiles,pos_npixstart,pos_pixstart,npix_cumsum,npixtot,run_label);

[fp,fn,fe] = fileparts(outfile);
main_header_combined.filename = [fn,fe];
main_header_combined.filepath = [fp,filesep];
%
data_sum= struct('main_header',main_header_combined,...
    'header',[],'detpar',det,'data',sqw_data);
data_sum.header = header_combined;

ds = sqw(data_sum);
wrtr = sqw_formats_factory.instance().get_pref_access('sqw');

if exist(outfile,'file') == 2 % init may want to upgrade the file and this
    delete(outfile);  %  is not the option we want to do here
end
wrtr = wrtr.init(ds,outfile);
wrtr = wrtr.put_sqw();
wrtr.delete();

%
%
function [main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
    read_input_headers(infiles)


% Read header information:
if ~iscell(infiles)
    infiles = {infiles};
end
nfiles = numel(infiles);

main_header=cell(nfiles,1);
header=cell(nfiles,1);
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
    header{i}      = ldrs{i}.get_header('-all');
    datahdr{i}     = ldrs{i}.get_data('-head');
    det_tmp        = ldrs{i}.get_detpar();
    if i==1
        det=det_tmp;    % store the detector information for the first file
    end
    if ~isequal_par(det,det_tmp); error('WRITE_NSQW_TO_SQW:invalid_argument',...
            'Detector parameter data is not the same in all files'); end
    clear det_tmp       % save memory on what could be a large variable
    
    %pos_datastart(i)=ldrs{i}.data_position;  % start of data block
    pos_npixstart(i)=ldrs{i}.npix_position;  % start of npix field
    pos_pixstart(i) =ldrs{i}.pix_position;   % start of pix field
    npixtot(i)      =ldrs{i}.npixels;
    mess_completion(i)
end
mess_completion
