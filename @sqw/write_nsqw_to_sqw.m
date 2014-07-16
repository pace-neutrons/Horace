function varargout = write_nsqw_to_sqw (dummy, infiles, wsqw, wsqw_sp, outfile)
% Combine a collection of sqw files &/or sqw objects &/or sparse sqw data structures with a common grid
%
% Create sqw file:
%   >> write_nsqw_to_sqw (dummy, infiles, wsqw, wsqw_sparse, outfile)
%
% Create sqw object:
%   >> wout = write_nsqw_to_sqw (dummy, infiles, wsqw, wsqw_sparse)
%
% Input:
% ------
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   infiles         Cell array or character array of sqw file name(s) of input file(s) (ignored if empty)
%   wsqw            Array of sqw objects to be combined (ignored if empty)
%   wsqw_sparse     Array of sparse sqw data structures to be combined (ignored if empty)
%   outfile         Full name of output sqw file
%                   If not given, then it is assumed that the output will be to an sqw object in memory
%
% Output:
% -------
%   <no output arguments>

% *** catch case of a single input data source - and deal with carefully

% T.G.Perring   27 June 2007
% T.G.Perring   22 March 2013  Modified to enable sqw files with more than one spe file to be combined.
% T.G.Perring   29 June 2014   Combine arbitrary sqw and sparse sqw ('tmp') files and objects with the same bins 
%
% $Revision$ ($Date$)


horace_info_level=get(hor_config,'horace_info_level');

npix_mem_max=1e9;   % maxmimum memory (bytes) to hold npix arrays read from file (excludes npix arrays in objects)
pix_mem_max=3e9;    % maxmimum memory (bytes) to hold pix arrays read from file (excludes pix arrays in objects)


% Check that the first argument is sqw object
% -------------------------------------------
if ~isa(dummy,classname)    % classname is a private method 
    error('Check type of input arguments')
end

% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if nargin==4 && nargout==0          % no output object, and no output file
    error ('Neither output sqw object nor output sqw file requested - routine is not being asked to do anything')
elseif nargin==4 && nargout==1      % output object, but no output file
    obj_out=true;
    file_out=false;
elseif nargin==5 && nargout==0      % no output object, but output file
    obj_out=false;
    file_out=true;
elseif nargin==5 && nargout==1      % output object and output file
    obj_out=true;
    file_out=true;
else
    error('Check number of input and output arguments')
end


% Check that the input files all exist
% ------------------------------------
% Convert to cell array of strings if necessary
if ~iscellstr(infiles)
    infiles=cellstr(infiles);
end

% Check input files exist
nfiles=length(infiles);
for i=1:nfiles
    if exist(infiles{i},'file')~=2
        error(['File ',infiles{i},' not found'])
    end
end

% *** Check output file can be opened, if one requested
% *** Check that output file and input files do not coincide


% Check that the sqw objects are all sqw type
% -------------------------------------------
nsqw=numel(wsqw);
for i=1:nsqw
    if ~is_sqw_type(wsqw(i))
        error(['Element ',num2str(i),' of the sqw object array does not contain pixel information i.e. is not sqw-type'])
    end
end

% Check the sparse data structures
% --------------------------------
% *** Currently is not a proper check of fields, as there is no true object of sqw_sparse format. Just catch silliness
nsqw_sp=numel(wsqw_sp);
if ~(isstruct(wsqw_sp) && isfield(wsqw_sp(1),'data') && isfield(wsqw_sp(1).data,'npix_nz'))
    error('Argument to contain sparse sqw data is not a structure or does not have a required field')
end


% Check consistency of header information
% ---------------------------------------
% At present we require that all detector info is the same for all data sources, and all spe files are distinct (in the
% sense defined below)

if horace_info_level>-1
	disp(' ')
	disp('Reading header(s) of input sqw data source(s) and checking consistency...')
end

% Read header information:
nsource=nsqw+nsqw_sp+nfiles;
main_header=cell(nsource,1);
header=cell(nsource,1);
datahdr=cell(nsource,1);
npixtot=zeros(nsource,1);
source=cell(nsource,1);
sparse_fmt=false(nsource,1);
data_type=cell(nsource,1);
pos_data_start=zeros(nsource,1);
pos_npix_start=zeros(nsource,1);
pos_npix_nz_start=zeros(nsource,1);
pos_ipix_nz_start=zeros(nsource,1);
pos_pix_nz_start=zeros(nsource,1);
pos_pix_start=zeros(nsource,1);

j=0;

% Parcel up the sqw object header information
for i=1:nsqw
    j=j+1;
    main_header{j}=wsqw(j).main_header;
    header{j}=wsqw(j).header;
    det_tmp=wsqw(i).detpar;
    datahdr{j}=data_to_dataheader(wsqw{i}.data);
    npixtot(j)=size(wsqw(i).data.pix,2);
    sparse_fmt(j)=false;
    if j==1, det=det_tmp; end   % store the detector information for the first file
    if ~isequal_par(det,det_tmp); error('Detector parameter data is not the same in all sqw objects'); end
    clear det_tmp       % save memory on what could be a large variable
end

% Parcel up the sparse sqw data structure header information
for i=1:nsqw_sp
    j=j+1;
    main_header{j}=wsqw_sp(j).main_header;
    header{j}=wsqw_sp(j).header;
    det_tmp=wsqw_sp(i).detpar;
    datahdr{j}=data_to_dataheader(wsqw_sp{i}.data);    
    npixtot(j)=size(wsqw_sp(i).data.pix,1);
    sparse_fmt(j)=true;
    if j==1, det=det_tmp; end   % store the detector information for the first file
    if ~isequal_par(det,det_tmp); error('Detector parameter data is not the same in all sparse sqw data structures'); end
    clear det_tmp       % save memory on what could be a large variable
end

% Get the header information from 
mess_completion(nfiles,5,0.1);   % initialise completion message reporting
for i=1:nfiles
    j=j+1;
    [mess,main_header{j},header{j},det_tmp,datahdr{j},position,npixtot(j),data_type{j},file_format,current_format] = get_sqw (infiles{i},'-h');
    if ~current_format; error('Data in file %s does not have current Horace format - please re-create',infiles{i}); end
    if ~isempty(mess); error('Error reading data from file %s \n %s',infiles{i},mess); end
    if ~(strcmpi(data_type{j},'a')||strcmpi(data_type{j},'sp')); error(['No pixel information in ',infiles{i}]); end
    source{j}=infiles{i};
    if strcmpi(data_type{j},'a'), sparse_fmt(j)=true; end
    pos_data_start(j)=position.data;    % start of data block
    pos_npix_start(j)=position.npix;    % start of npix field
    pos_npix_nz_start(j)=position.npix_nz;  % start of npix_nz field
    pos_ipix_nz_start(j) =position.ipix_nz; % start of ipix field
    pos_pix_nz_start(j)=position.pix_nz;    % start of npix_nz field
    pos_pix_start(j) =position.pix;     % start of pix field
    if j==1, det=det_tmp; end   % store the detector information for the first file
    if ~isequal_par(det,det_tmp); error('Detector parameter data is not the same in all files'); end
    clear det_tmp       % save memory on what could be a large variable
    mess_completion(i)
end
mess_completion


% Check consistency:
% At present, we insist that the contributing spe data are distinct in that:
%   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
%   - emode, lattice parameters, u, v, sample must be the same for all spe data input
% This guarantees that the pixels are independent (the data may be the same if an spe file name is repeated, but
% it is assigned a different Q, and is in the spirit of independence)
[header_combined,nspe,ok,mess] = header_combine(header);
if ~ok, error(mess), end

% We must have same data information for alatt, angdeg, uoffset, u_to_rlu, ulen, pax, iint, p

% Number of projection axes and size of signal array
npax=length(datahdr{1}.pax);
sz=zeros(1,npax);
for i=1:npax
    sz(i)=numel(datahdr{i}.pax)-1;
end

% Consistency check:
tol = 4*eps(single(1)); % test number to define equality allowing for rounding
for i=2:nsource  % only need to check if more than one data source
    ok = equal_to_relerr(datahdr{i}.uoffset, datahdr{1}.uoffset, tol, 1);
    ok = ok & equal_to_relerr(datahdr{i}.u_to_rlu(:), datahdr{1}.u_to_rlu(:), tol, 1);
    if ~ok
        error('Input files must all have the same projection axes and projection axes offsets in the data blocks')
    end

    if length(datahdr{i}.pax)~=npax
        error('Input files must all have the same number of projection axes')
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
            % Absolute tolerance of maximum bin boundary value written to file in single precision
            % This sets the absolute tolerance for all bin boundaries
            abs_tolaxis=4*eps(single(max(abs([datahdr{i}.p{ipax}(1),datahdr{i}.p{ipax}(end)]))));
            ok = ok & (numel(datahdr{i}.p{ipax})==numel(datahdr{i}.p{ipax}) &...
                max(abs(datahdr{i}.p{ipax}-datahdr{1}.p{ipax}))<abs_tolaxis);
        end
        if ~ok
            error('Not all projection axes and bin boundaries are identical')
        end
    end
end


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

npix_in_memory=true;
pix_in_memory=true;
npix=cell(nsource,1);      % to hold the npix arrays
npix_nz=cell(nsource,1);   % to hold the npix_nz arrays
ipix_nz=cell(nsource,1);   % to hold the ipix_nz arrays
pix_nz=cell(nsource,1);    % to hold the pix_nz arrays
pix=cell(nsource,1);       % to hold the ipix arrays

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
        ipix_nz{j}=wsqw_sp(i).data.ipix_nz;
        pix_nz{j}=wsqw_sp(i).data.pix_nz;
        pix{j}=wsqw_sp(i).data.pix;
        s_accum = s_accum + (wsqw_sp(i).data.s).*npix{j};       % s_accum is full, so sparse intermediate in the accumulation is converted
        e_accum = s_accum + (wsqw_sp(i).data.e).*(npix{j}.^2);
        npix_accum = npix_accum + npix{j};
    end
end

% Process sqw filea:
if nfiles>0
    if horace_info_level>-1, disp(' - processing sqw file(s)...'), end
    npix_mem=0;     % only additional memory needed to hold data from files needs to be monitored
    pix_mem=0;      % similarly
    mess_completion(nfiles,5,0.1);   % initialise completion message reporting
    for i=1:nfiles
        j=j+1;
        fid=fopen(infiles{i},'r');
        if fid<0; error(['Unable to open input file ',infiles{i}]); end
        status=fseek(fid,pos_data_start(i),'bof'); % Move directly to location of start of data section
        if status<0; fclose(fid); error(['Error finding location of binning data in file ',infiles{i}]); end
        [mess,bindata]=get_sqw_data(fid,'-nopix',file_format,data_type{j});
        if ~isempty(mess); error('Error reading data from file %s \n %s',infiles{i},mess); end
        % Append npix and npix_nz (if applicable) to corresponding cell arrays - if enough memory
        if npix_in_memory
            if (npix_mem+get_num_bytes(bindata.npix)<=npix_mem_max)
                npix_mem=npix_mem+get_num_bytes(bindata.npix);
                npix{j}=bindata.npix;
            else
                npix_in_memory=false;
                npix=cell(nsource,1);      % re-initialise for consistency
                npix_nz=cell(nsource,1);   % re-initialise for consistency
            end
            if npix_in_memory && sparse_fmt(j) && (npix_mem+get_num_bytes(bindata.npix_nz)<=npix_mem_max)
                npix_mem=npix_mem+get_num_bytes(bindata.npix_nz);
                npix_nz{j}=bindata.npix_nz;
            else
                npix_in_memory=false;
                npix=cell(nsource,1);      % re-initialise for consistency
                npix_nz=cell(nsource,1);   % re-initialise for consistency
            end
        end
        % Append ipix_nz, pix_nz and pix (if applicable) to corresponding cell arrays - if enough memory
        if pix_in_memory
            if (pix_mem+get_num_bytes(bindata.pix)<=pix_mem_max)
                pix_mem=pix_mem+get_num_bytes(bindata.pix);
                pix{j}=bindata.pix;
            else
                pix_in_memory=false;
                pix_nz=cell(nsource,1);   % re-initialise for consistency
                ipix_nz=cell(nsource,1);  % re-initialise for consistency
                pix=cell(nsource,1);      % re-initialise for consistency
            end
            if pix_in_memory && sparse_fmt(j) && (pix_mem+get_num_bytes(bindata.ipix_nz)+get_num_bytes(bindata.pix_nz)<=pix_mem_max)
                pix_mem=pix_mem+get_num_bytes(bindata.ipix_nz)+get_num_bytes(bindata.pix_nz);
                ipix_nz{j}=bindata.ipix_nz;
                pix_nz{j}=bindata.pix_nz;
            else
                pix_in_memory=false;
                pix_nz=cell(nsource,1);   % re-initialise for consistency
                ipix_nz=cell(nsource,1);  % re-initialise for consistency
                pix=cell(nsource,1);      % re-initialise for consistency
            end
        end
        % Accumulate s,e,npix
        s_accum = s_accum + (bindata.s).*(bindata.npix);
        e_accum = e_accum + (bindata.e).*(bindata.npix).^2;
        npix_accum = npix_accum + bindata.npix;
        fclose(fid);            % close file so that do not have lots of files open at once
        clear bindata
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


% Write to output file
% ---------------------------
if horace_info_level>-1
    disp(' ')
    disp(['Writing to output file ',outfile,' ...'])
end

nfiles_tot=sum(nspe);
main_header_combined.filename='';
main_header_combined.filepath='';
main_header_combined.title='';
main_header_combined.nfiles=nfiles_tot;

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

run_label=cumsum([0;nspe(1:end-1)]);

% Package source information about pixels


pix_info=struct('source',{source},'sparse',sparse_fmt,...
    'npix',{npix},'npix_nz',{npix_nz},'ipix_nz',{ipix_nz},'pix_nz',{pix_nz},'pix',{pix},...
    'pos_npix_start',pos_npix_start,'pos_npix_nz_start',pos_npix_nz_start,'pos_ipix_nz_start',pos_ipix_nz_start,...
    'pos_pix_nz_start',pos_pix_nz_start,'pos_pix_start',pos_pix_start,...
    'spec_to_pix',spec_to_pix,'spec_to_rlu',spec_to_rlu,'detdcn',detdcn);

% Write to file
mess = put_sqw (outfile, main_header_combined, header_combined, det, sqw_data, '-pix', pix_info, run_label);
if ~isempty(mess); error('Problems writing to output file %s \n %s',outfile,mess); end
