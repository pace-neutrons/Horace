function varargout = combine (varargin)
% Combine a collection of sqw files &/or sqw objects &/or sparse sqw data structures
%
% Create sqw object:
%   >> wout = combine (s1, s2, s3,...)
%
% Create sqw file:
%   >> combine (s1, s2, s3,..., outfile)
%
% Input:
% ------
%   s1, s2,...  Data to be combined. Each of s1, s2, s3,... can be one of
%               - sqw file name, or cell array of sqw file names (if a name
%                is empty it is ignored)
%               - sqw object or array of sqw objects (if an object matches
%                the empty sqw object it is ignored)
%               - sparse sqw data structure or array of sparse sqw structures
%                (if an object 
%
%   outfile     [Optional] Full name of output sqw file
%               If not given, then it is assumed that the output will be to
%               an sqw object in memory
%
% Output:
% -------
%   wout        [Optional] sqw object with combined data
%               If not given, then it is assumed that an output file name was given


% Original author: T.G.Perring
%
% $Revision: 880 $ ($Date: 2014-07-16 08:18:58 +0100 (Wed, 16 Jul 2014) $)
%
% T.G.Perring   27 June 2007    Original function - called write_nsqw_to_sqw
% T.G.Perring   22 March 2013   Modified to enable sqw files with more than one spe file to be combined.
% T.G.Perring   29 June 2014    Renamed combine; merges an arbitrary collection of 
%                               sqw and sparse sqw files and objects with the same bins 


% *** catch case of a single input data source - and deal with carefully


horace_info_level=get(hor_config,'horace_info_level');

mem_max_sqw=4e9;    % maximum memory (bytes) which is allowed for all sqw data


% Check that the input data sources are valid
% -------------------------------------------
if nargout==1
    file_output=false;
else
    file_output=true;
end
[ok,mess,wsqw,wsqw_sp,infiles,outfile] = combine_parse_input (file_output,varargin{:});
if ~ok
    error(mess)
end

nsqw=numel(wsqw);
nsqw_sp=numel(wsqw_sp);
ninfiles=numel(infiles);
nsource=nsqw+nsqw_sp+ninfiles;


% Catch case of just a single input data source
% ---------------------------------------------
% This is a trivial case where nothing has to be combined
if nsource==1
    error('Only one data source - nothing to be combined')
end



% =================================================================================================
% Check consistency of header information
% =================================================================================================
% Read header information
% -----------------------
if horace_info_level>-1
	disp(' ')
	disp('Reading header(s) of input sqw data source(s) and checking consistency...')
end


S=cell(nsource,1);
sparse_fmt=false(nsource,1);
header=cell(nsource,1);
datahdr=cell(nsource,1);
nfiles=zeros(nsource,1);
npixtot=zeros(nsource,1);

j=0;    % count sqw data sets

% Parcel up the sqw object header information
for i=1:nsqw
    j=j+1;
    sparse_fmt(j)=false;
    header{j}=wsqw(i).header;
    datahdr{j}=data_to_dataheader(wsqw(i).data);
    nfiles(j)=wsqw(i).main_header.nfiles;
    npixtot(j)=size(wsqw(i).data.pix,2);
    if j>1
        if ~detpar_equal(wsqw(i).detpar,detpar); error('Detector parameter data is not the same in all sqw data sets'); end
    else
        detpar=wsqw(i).detpar;     % store the detector information for the first file
    end
end

% Parcel up the sparse sqw data structure header information
for i=1:nsqw_sp
    j=j+1;
    sparse_fmt(j)=true;
    header{j}=wsqw_sp(i).header;
    datahdr{j}=data_to_dataheader(wsqw_sp(i).data);    
    nfiles(j)=wsqw_sp(i).main_header.nfiles;
    npixtot(j)=size(wsqw_sp(i).data.pix,1);
    if j>1
        if ~detpar_equal(wsqw_sp(i).detpar,detpar); error('Detector parameter data is not the same in all sqw data sets'); end
    else
        detpar=wsqw_sp(i).detpar;  % store the detector information for the first file
    end
end

% Get the header information from sqw files
cur_fmt = fmt_check_file_format();
mess_completion(ninfiles,5,0.1);   % initialise completion message reporting
for i=1:ninfiles
    j=j+1;
    [w,ok,mess,S{j}] = get_sqw (infiles{i},'-h');
    if ~isempty(mess); error('Error reading data from file %s \n %s',infiles{i},mess); end
    if S{j}.application.file_format~=cur_fmt; error('Data in file %s does not have current Horace format - please re-create',infiles{i}); end
    info=S{j}.info;
    if ~info.sqw_type; error(['No pixel information in ',infiles{i}]); end
    sparse_fmt(j)=info.sparse;
    header{j}=w.header;
    datahdr{j}=w.data;
    nfiles(j)=info.nfiles;
    npixtot(j)=info.npixtot;
    if j>1
        if ~detpar_equal(w.detpar,detpar); error('Detector parameter data is not the same in all sqw data sets'); end
    else
        detpar=w.detpar;   % store the detector information for the first file
    end
    mess_completion(i)
end
mess_completion


% Check consistency of run headers
% --------------------------------
% Check that the headers permit combining the sqw data
[header_combined,run_label,ok,mess] = header_combine(header);
if ~ok, error(mess), end


% Check consistency of data headers
% ---------------------------------
% We must have same data information for:
%       alatt, angdeg, uoffset, u_to_rlu, ulen, iax, iint, pax, p
% We assume that the alatt and angdeg are already all equal, as the sqw header
% blocks have already passed, and in a valid sqw object the alatt and angdeg
% should be the same as those in the data block.

% *** Can generalise:
%       - the bin boundaries only need to be commensurate. THe s,e,npix arrays
%         could be offset inside an encompassing array
%       - the data could be re-cut to be commensurate (and same dimensionality)
%         as the first object. Hold the re-cut data in a temporary variable or file.

% Number of projection axes and size of signal array
npax=length(datahdr{1}.pax);
sz=ones(1,max(npax,2));
for i=1:npax
    sz(i)=numel(datahdr{1}.p{i})-1;
end

% Consistency check:
tol = 1e-14;        % test number to define equality allowing for rounding
for i=2:nsource     % only need to check if more than one data source
    ok = equal_to_relerr(datahdr{i}.uoffset, datahdr{1}.uoffset, tol, 1);
    ok = ok & equal_to_relerr(datahdr{i}.u_to_rlu(:), datahdr{1}.u_to_rlu(:), tol, 1);
    if ~ok
        error('Data to be combined must all have the same projection axes and projection axes offsets in the data blocks')
    end

    if length(datahdr{i}.pax)~=npax
        error('Data to be combined must all have the same number of projection axes')
    end
    if npax<4   % one or more integration axes
        ok = all(datahdr{i}.iax==datahdr{1}.iax);
        ok = ok & equal_to_relerr(datahdr{i}.iint, datahdr{1}.iint, tol, 1);
        if ~ok
            error('Not all integration axes and integration limits are identical')
        end
    end
    if npax>0   % one or more projection axes
        ok = all(datahdr{i}.pax==datahdr{1}.pax);
        for ipax=1:npax
            % Absolute tolerance of maximum bin boundary value written to file in double precision
            % This sets the absolute tolerance for all bin boundaries
            abs_tolaxis=4*eps(max(abs([datahdr{i}.p{ipax}(1),datahdr{i}.p{ipax}(end)])));
            ok = ok & (numel(datahdr{i}.p{ipax})==numel(datahdr{i}.p{ipax}) &...
                max(abs(datahdr{i}.p{ipax}-datahdr{1}.p{ipax}))<abs_tolaxis);
        end
        if ~ok
            error('Not all projection axes and bin boundaries are identical')
        end
    end
end


% =================================================================================================
% Now read in binning information
% ---------------------------------
% We did not read in the arrays s, e, npix from the files because if have a 50^4 grid then the size of the three
% arrays is is total 24*50^4 bytes = 150MB. Firstly, we cannot afford to read all of these arrays as it would
% require too much RAM (30GB if 200 spe files); also if we just want to check the consistency of the header information
% in the files first we do not want to spend lots of time reading and accumulating the s,e,npix arrays. We can do
% that now, as we have checked the consistency.

if horace_info_level>-1 
	disp(' ')
	disp('Accumulating binning information of input data source(s)...')
end

s_accum=zeros(sz);
e_accum=zeros(sz);
npix_accum=zeros(sz);

npix=cell(nsource,1);
npix_nz=cell(nsource,1);
pix_nz=cell(nsource,1);
pix=cell(nsource,1);

j=0;

% Process sqw objects
if nsqw>0
    if horace_info_level>-1, disp(' - processing sqw object(s)...'), end
    for i=1:nsqw
        j=j+1;
        npix{j}=wsqw(i).data.npix;
        pix{j}=wsqw(i).data.pix;
        s_accum = s_accum + ((wsqw(i).data.s).*npix{j});
        e_accum = s_accum + ((wsqw(i).data.e).*(npix{j}.^2));
        npix_accum = npix_accum + npix{j};
    end
end

% Process sparse sqw data structures
if nsqw_sp>0
    if horace_info_level>-1, disp(' - processing sparse format sqw data structure(s)...'), end
    for i=1:nsqw_sp
        j=j+1;
        npix{j}=wsqw_sp(i).data.npix;
        npix_nz{j}=wsqw_sp(i).data.npix_nz;
        pix_nz{j}=wsqw_sp(i).data.pix_nz;
        pix{j}=wsqw_sp(i).data.pix;
        s_accum = s_accum + (wsqw_sp(i).data.s).*npix{j};       % s_accum is full, so sparse intermediate in the accumulation is converted
        e_accum = s_accum + (wsqw_sp(i).data.e).*(npix{j}.^2);
        npix_accum = npix_accum + npix{j};
    end
end

% Process sqw files:
% To minimise IO operations and repeated OS &/or diskcache re-buffering of data, read in as many
% of npix, npix_nz, pix_nz, pix as our memory reserves allow.

% Compute memory needs of arrays in files
keep_npix=false;
keep_npix_nz=false;
keep_pix_nz=false;
keep_pix=false;
mem_tot = get_num_bytes(wsqw) + get_num_bytes(wsqw_sp);
if mem_tot<mem_max_sqw
    [mem_npix,mem_npix_nz,mem_pix_nz,mem_pix]=sources_file_mem_req(S);
    if mem_tot+mem_npix<mem_max_sqw; keep_npix=true; end
    if mem_tot+mem_npix+mem_npix_nz<mem_max_sqw; keep_npix_nz=true; end
    if mem_tot+mem_npix+mem_npix_nz+mem_pix_nz<mem_max_sqw; keep_pix_nz=true; end
    if mem_tot+mem_npix+mem_npix_nz+mem_pix_nz+mem_pix<mem_max_sqw; keep_pix=true; end
end

if ninfiles>0
    if horace_info_level>-1, disp(' - processing sqw file(s)...'), end
    mess_completion(ninfiles,5,0.1);   % initialise completion message reporting
    for i=1:ninfiles
        j=j+1;
        % Open file
        [S{j},mess]=sqwfile_open(infiles{i},'readonly');
        if ~isempty(mess); tidy_close(S); error('Error reading data from file %s \n %s',infiles{i},mess); end

        % Read s,e,npix (and headers and detectors again, but that's OK)
        w = get_sqw (S{j},'-dnd');
        
        % Keep npix if can, and read and keep npix_nz, pix_nz, pix if can
        if keep_npix, npix{i}=w.data.npix; end
        if S{j}.info.sparse
            if keep_npix_nz, npix_nz{j} = get_sqw (S{j},'npix_nz'); end
            if keep_pix_nz, pix_nz{j} = get_sqw (S{j},'pix_nz'); end
        end
        if keep_pix
            pix_nz{j} = get_sqw (S{j},'pix_nz');
            S{j}=sqwfile_close(S{j});   % can close the file, as all required data is in memory
        end

        % Accumulate s,e,npix
        s_accum = s_accum + (w.data.s).*(w.data.npix);
        e_accum = e_accum + (w.data.e).*(w.data.npix).^2;
        npix_accum = npix_accum + w.data.npix;

        mess_completion(i)
    end
end
mess_completion

% Create output signal and error arrays
s_accum = s_accum ./ npix_accum;
e_accum = e_accum ./ npix_accum.^2;
nopix=(npix_accum==0);
s_accum(nopix)=0;
e_accum(nopix)=0;
clear nopix


% =================================================================================================
% Write to output file
% ---------------------------
if horace_info_level>-1
    disp(' ')
    disp(['Writing to output file ',outfile,' ...'])
end

main_header_combined.filename='';
main_header_combined.filepath='';
main_header_combined.title='';
if iscell(header_combined)
    main_header_combined.nfiles=numel(header_combined);
else
    main_header_combined.nfiles=1;
end

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
sqw_data.s=s_accum;
sqw_data.e=e_accum;
sqw_data.npix=npix_accum;
sqw_data.urange=datahdr{1}.urange;
for j=2:nsource
    sqw_data.urange=[min(sqw_data.urange(1,:),datahdr{i}.urange(1,:));max(sqw_data.urange(2,:),datahdr{i}.urange(2,:))];
end


% Package source information
wout.main_header=main_header_combined;
wout.header=header_combined;
wout.detpar=detpar;
wout.data=sqw_data;

src=struct('S',S,'sparse_fmt',sparse_fmt,'nfiles',nfiles,'npix',npix,'npix_nz',npix_nz,'pix_nz',pix_nz,'pix',pix);

% Write to file
[ok,mess,Sout] = put_sqw (file, wout, '-pix', src, header_combined, detpar, run_label, npix_accum);
if ~isempty(mess); error('Problems writing to output file %s \n %s',outfile,mess); end


%==================================================================================================
function tidy_close(S)
% Close all open files in an array of sqwfile structures
for i=1:numel(S)
    fid=S(i).fid;
    if fid>=3 && ~isempty(fopen(fid))
        fclose(fid);
    end
end
