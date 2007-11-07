function cut = cut_sqw (data_source, proj_in, varargin)
% Reads an sqw file or data structure and creates a 0,1,2,3 or 4D data set
% by integrating over one of the momentum or energy axes.
% 
% Syntax:
%  make cut:
%   >> cut = cut_sqw (data_source, proj, p1_bin, p2_bin, p3_bin)
%   >> cut = cut_sqw (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)
%   >> cut = cut_sqw (..., '-pix')           % cut is full sqw structure
%
%  save to file only:
%   >> cut_sqw (..., '-save')                % Save full sqw data structure to file (prompt for output file)
%   >> cut_sqw (...,  filename)              % save full sqw data structure to named file
%
%  make cut and save to file:
%   >> cut = cut_sqw (...,'-save')           % create cut, and save full structure to file (prompt for output file)
%   >> cut = cut_sqw (..., filename)         % create cut, and save full structure to named file
%   >> cut = cut_sqw (..., '-pix','-save')   % create cut with full structure and save full sqw data structure to file (prompt for output file)
%   >> cut = cut_sqw (..., '-pix', filename) % create cut with full structure and save full sqw data structure to named file
% 
% Input:
% ------
%   data_source     Data source: sqw file name or data structure
%
%   proj            Data structure containing details of projection axes:
%                  Defines two vectors u and v that give the direction of u1
%                 (parallel to u) and u2 (in the plane of u1 and u2, with u2
%                  having positive component along v); also defines the 
%                  normalisation of u1,u2,u3
%                   Required arguments:
%                       proj.u          [1x3] Vector of first axis (r.l.u.)
%                       proj.v          [1x3] Vector of second axis (r.l.u.)
%                   Optional arguments:
%                       proj.type       [1x3] Char. string defining normalisation:
%                           [each character indicates if u1, u2, u3 normalised to Angstrom^-1 ('a'), or
%                           r.l.u., max(abs(h,k,l))=1 ('r');  e.g. type='arr']
%                           Default: 'rrr'
%                       proj.uoffset    Row or column vector of offset of origin of projection axes (r.l.u.)
%                       proj.lab1       Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%                       proj.lab2       Short label for u2 axis
%                       proj.lab3       Short label for u3 axis
%                       proj.lab4       Short label for u4 axis (e.g. 'E' or 'En')
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%               - [] or ''          Empty array=integration axis: equivalent to [-Inf,Inf]
%               - [pstep]           Plot axis: sets step size; plot limits
%                                  taken from extent of the data
%               - [plo, phi]        Integration axis: range of integration
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%
%   p4_bin          [Optional] binning along the energy axis:
%               - omit              Plot axis: energy binning of first .spe file;
%                                  plot limits from extent of the data
%               - [] or ''          Empty array=integration axis: equivalent to [-Inf,Inf]
%               - [pstep]           Plot axis: sets step size; plot limits taken
%                                  from extent of the data
%                                   If step=0 then use bin size of first .spe file
%               - [plo, phi]        Integration axis: range of integration
%           	- [plo, pstep, phi]	Plot axis: minimum and maximum bin centres and step size;
%                                  If step=0 then use bin size of default input array of bin boundaries, en, and
%                                  the boundaries are commensurate with those of en. The bin range is chosen to ensure
%                                  that the energy range plo to phi is contained within the bin boundaries.
%           
%
% Output:
% -------
%   cut            Output data object:
%                     - Horace n-dimensional object (d0d,d1d...d4d) by default
%                     - sqw data structure if keyword 'pix' given
%
% EXAMPLES
%   >> proj = {[1,1,0],[0,0,1],'rrr',[1,-1,0]};
%   >> d = slice_3d ('RbMnF3.sqw', proj, [0.4,0.5], [-1,0.025,2], [-2,0.025,2])

% T.G.Perring   04/07/2007

% *** currently does not work for zero dimensional output: small issue to sort out
bigtic
small = 1.0d-10;    % 'small' quantity for cautious dealing of borders, testing matricies are diagonal etc.


% Parse input arguments
% ---------------------
% strip off up to final arguments that are character strings, and parcel the rest as binning arguments
% (the functions that use binning arguments are clever enough to handle incorrect number of arguments and types)
opt=cell(1,0);
if length(varargin)>=1 && ischar(varargin{end}) && size(varargin{end},1)==1
    opt{1}=varargin{end};
end
if length(varargin)>=2 && ischar(varargin{end-1}) && size(varargin{end-1},1)==1
    opt{2}=varargin{end-1};
end
pbin=varargin(1:end-length(opt));

% Check consistency of options and output arguments.
% (*** do some checks for which there is reasonable default behaviour, but as cuts can take a long time, be cautious instead)
pix_to_cut=false;
save_to_file=false;
outfile='';
if length(opt)==1
    if strncmpi(opt{1},'-pix',max(length(opt{1}),2))
        pix_to_cut=true;
    elseif strncmpi(opt{1},'-save',max(length(opt{1}),2))
        save_to_file=true;
    else
        save_to_file=true;
        outfile=opt{1};
    end
elseif length(opt)==2
    if (strncmpi(opt{1},'-pix',max(length(opt{1}),2)) && strncmpi(opt{2},'-save',max(length(opt{2}),2))) ||...
       (strncmpi(opt{1},'-save',max(length(opt{1}),2)) && strncmpi(opt{2},'-pix',max(length(opt{2}),2)))
        pix_to_cut=true;
        save_to_file=true;
    elseif strncmpi(opt{1},'-pix',max(length(opt{1}),2))
        pix_to_cut=true;
        save_to_file=true;
        outfile=opt{2};        
    elseif strncmpi(opt{2},'-pix',max(length(opt{2}),2))
        pix_to_cut=true;
        save_to_file=true;
        outfile=opt{1};
    else
        error('Check optional arguments: ''%s'' and ''%s''',opt{1},opt{2})
    end
end

if nargout==0 && ~save_to_file  % Check work needs to be done (*** might want to make this case prompt to save to file)
    error ('Neither output cut nor output file requested - routine is not being asked to do anything')
end

if nargout==0 && pix_to_cut     % (*** might want to make default to ignoring redundant option)
    error ('Option ''-pix'' not valid if no output cut requested')
end

if save_to_file && ~isempty(outfile)    % check file name makes reasonable sense 
    [out_path,out_name,out_ext,out_ver]=fileparts(outfile);
    if length(out_ext)<=1    % no extension or just a dot
        error('Output filename ''%s'' has no extension - check optional arguments',outfile)
    end
end

% Set internal flags that control retaining of pixel information and if buffering to temporary files is permitted
keep_pix = false;
pix_tmpfile_ok = false;
if save_to_file || pix_to_cut
    keep_pix = true;
end
if save_to_file && ~pix_to_cut
    pix_tmpfile_ok = true;
end

% Open output file if required
if save_to_file
    if isempty(outfile)
        outfile = genie_putfile('*.sqw');
        if (isempty(outfile))
            error ('No output file name given')
        end
    end
    % Open output file now - don;t want to discover there are problems after 30 seconds of calculation
    fout = fopen (outfile, 'W');
    if (fout < 0)
        error (['Cannot open output file ' outfile])
    end
end

% Get header information from the input file
% --------------------------------------------
disp('--------------------------------------------------------------------------------')
if isa_size(data_source,'row','char') && (exist(data_source,'file') && ~exist(data_source,'dir'))  % data_source is a file
    source_is_file = 1;     % flag to indicate nature of data source
    filename = data_source;        % make copy of file name before it is overwritten as a structure
    disp(['Taking cut from data in file ',filename,'...'])
    [main_header,header,detpar,data,mess,position,npixtot,type]=get_sqw (filename,'-nopix');
    if ~isempty(mess)
        error('Error reading data from file %s \n %s',filename,mess)
    end
    if ~strcmpi(type,'a')
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error('Data file is not sqw file with pixel information - cannot take cut')
    end
else
    source_is_file = 0;
    disp('Taking cut from sqw data structure...')
    % check that the structure is valid
    if isstruct(data_source)
        mess = sqw_checkfields (data_source);
        if ~isempty(mess)
            if save_to_file; fclose(fout); end    % close the output file opened earlier
            error ('Input structure does not have a valid sqw dataset structure')
        end
        if ~strcmpi(sqw_type(data_source.data),'a')
            if save_to_file; fclose(fout); end    % close the output file opened earlier
            error('sqw data structure does not contain pixel information - cannot take cut')
        end
    else
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error ('Input data source must be a sqw file or a sqw data structure')
    end
    % for convenience, unpack the fields that themselves are major data structures
    %(no memory penalty as matlab just passes pointers)
    main_header = data_source.main_header;
    header = data_source.header;
    detpar = data_source.detpar;
    data = data_source.data;
    if ~isfield(data,'npix')    % sqw data structure is of the type that does not hold individual pixel info
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error('sqw data structure does not hold pixel information - unable to take cut')
    else
        npixtot = size(data.pix,2);
    end
end


% Check the proj data structure is valid
% --------------------------------------------
[proj,mess] = proj_fill_fields(proj_in);
if ~isempty(mess)
    if save_to_file; fclose(fout); end    % close the output file opened earlier
    error(mess)
end


% Get some 'average' quantities for use in calculating transformations and bin boundaries
% -----------------------------------------------------------------------------------------
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines
if iscell(header)
    header_ave = header{1};
else
    header_ave = header;
end
alatt = header_ave.alatt;
angdeg = header_ave.angdeg;
en = header_ave.en;  % energy bins for synchronisation with when constructing defaults
upix_to_rlu = header_ave.u_to_rlu(1:3,1:3);
upix_offset = header_ave.uoffset;


% Get matrix to convert from projection axes of input data to required output projection axes
% ---------------------------------------------------------------------------------------------
% The conversion here is that for the projection axes in which the plot and integration axes of the data section
% are expressed. Recall that this is not necessarily the same as that in which the individual pixel information is
% expressed.

uin_to_rlu = data.u_to_rlu(1:3,1:3);
uin_offset = data.uoffset;

[rlu_to_ustep, u_to_rlu, ulen, mess] = rlu_to_ustep_matrix (alatt, angdeg, proj.u, proj.v, [1,1,1], proj.type);
rot = inv(u_to_rlu)*uin_to_rlu;         % convert components from data input proj. axes to output proj. axes
trans = inv(uin_to_rlu)*(proj.uoffset(1:3)-uin_offset(1:3));  % offset between the origins of input and output proj. axes, in input proj. coords


% Get plot and integration axis information, and which blocks of data to read from file/structure
% ------------------------------------------------------------------------------------------------
[iax, iint, pax, p, urange, mess] = cut_sqw_calc_ubins (data.urange, rot, trans, en, pbin);
if ~isempty(mess)   % problem getting limits from the input
    if save_to_file; fclose(fout); end    % close the output file opened earlier
    error(mess)
end

% Get the start and end index of contiguous blocks of pixel information in the data
% *** should use optimisation for cases when rot is diagonal ?
border = small*[-1,-1,-1,-1;1,1,1,1];   % put a small border around the range to ensure we don't miss any
                                        % pixels on the boundary because of rounding errors in get_nrange_rot_section
                                        
% Construct arrays of bin boundaries that include integration axes as bins of zero length
% (Need to go through the following for the case when have data structure with less than four plot axes)
pin=cell(1,4);
pin(data.pax)=data.p;
pin(data.iax)=mat2cell(data.urange(:,data.iax),2,ones(1,length(data.iax)));
for i=1:4
    nbin_in(i)=length(pin{i})-1;
end
% Reshape of data.npix is following line is necessary to insert singleton dimensions for integration axes
[nstart,nend] = get_nrange_rot_section (urange+border, rot, trans, reshape(data.npix,nbin_in), pin{:});


% Get matrix, and offset in pixel proj. axes, that convert from coords in pixel proj. axes to multiples of step from lower point of range
% ---------------------------------------------------------------------------------------------------------------------------------------------
%  (Step size of zero is possible e.g. integration range is zero over what we know is exactly zero for Qz on HET west bank
% or energy transfer if select constant-E plane exactly at bin centre)
%  In the cutting algorithm, plot axes with one bin only will be treated exactly as integration axes; we can always reshape the output
% to insert singleton dimensions as required.
%  (*** Implicitly assumes that there is no energy offset in uoffset, either in the input data or the requested output proj axes
%   *** Will need to modify get_nrange_rot_section, cut_sqw_calc_ubins and routines they call to handle this.)

% Get plot axes with two or more bins, and the number of bins along those axes
j=1;
pax_gt1=[];
nbin_gt1=[];
ustep_gt1=[];
for i=1:length(pax)
    if length(p{i})>2
        pax_gt1(j)=pax(i);              % row vector of plot axes with two or more bins
        nbin_gt1(j)=length(p{i})-1;     % row vector of number of bins
        ustep_gt1(j)=(p{i}(end)-p{i}(1))/(length(p{i})-1);  % row vector of bin widths
        j=j+1;
    end
end

% Set range and step size for plot axes with two or more bins to be the permitted range in multiples of the bin width
% Treat other axes as unit step length, range in units of output proj. axes
urange_step=urange;             % range expressed as steps/length of output ui
urange_offset = zeros(1,4);     % offset for start of measurement as lower left corner/origin as defined by uoffset
ustep = ones(1,4);              % step as multiple of unit ui/unity
if ~isempty(pax_gt1)
    urange_step(:,pax_gt1)=[zeros(1,length(pax_gt1));nbin_gt1];
    urange_offset(pax_gt1)=urange(1,pax_gt1);
    ustep(pax_gt1)=ustep_gt1;
end

% Get matrix and translation vector to express plot axes with two or more bins as multiples of step size from lower limits
[rlu_to_ustep, u_to_rlu, ulen, mess] = rlu_to_ustep_matrix (alatt, angdeg, proj.u, proj.v, ustep(1:3), proj.type);
rot_ustep = rlu_to_ustep*upix_to_rlu; % convert from pixel proj. axes to steps of output projection axes
trans_bott_left = inv(upix_to_rlu)*(proj.uoffset(1:3)-upix_offset(1:3)+u_to_rlu*urange_offset(1,1:3)'); % offset between origin
                        % of pixel proj. axes and the lower limit of hyper rectangle defined by range of data , expressed in pixel proj. coords
ebin=ustep(4);                  % plays role of rot_ustep for energy
trans_elo = urange_offset(1,4); % plays role of trans_bott_left for energy
                  

% Get accumulated signal
% -----------------------
% read data and accumulate
if source_is_file
    fid=fopen(filename,'r');
    if fid<0
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error(['Unable to open file ',filename])
    end
    status=fseek(fid,position.pix,'bof');    % Move directly to location of start of pixel data block
    if status<0;
        fclose(fid);
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error(['Error finding location of pixel data in file ',filename]);
    end
    [s, e, npix, urange_step_pix, pix, npix_retain, npix_read] = cut_data_from_file (fid, nstart, nend, keep_pix, pix_tmpfile_ok,...
                                                urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax_gt1, nbin_gt1);
    fclose(fid);
else
    [s, e, npix, urange_step_pix, pix, npix_retain, npix_read] = cut_data_from_array (data.pix, nstart, nend, keep_pix, ...
                                                urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax_gt1, nbin_gt1);
end
% For convenience later on, set a flag that indicates if pixel info buffered in files
if isstruct(pix)
    pix_tmpfile=true;
else
    pix_tmpfile=false;
end
    
% Convert range from steps to actual range with respect to output uoffset:
urange_pix = urange_step_pix.*repmat(ustep,[2,1]) + repmat(urange_offset,[2,1]);

% Account for singleton dimensions i.e. plot axes with just one bin (and look after case of zero or one dimension)
nbin=[];
for i=1:length(pax)
    nbin(i)=length(p{i})-1;
end
if isempty(nbin); nbin_as_size=[1,1]; elseif length(nbin)==1; nbin_as_size=[nbin,1]; else nbin_as_size=nbin; end;  % usual Matlab sillyness
s = reshape(s,nbin_as_size);
e = reshape(e,nbin_as_size);
npix = reshape(npix,nbin_as_size);


% Parcel up data as the output sqw data structure
% -------------------------------------------------
data_out.uoffset = proj.uoffset;
data_out.u_to_rlu = [[u_to_rlu,[0;0;0]];[0,0,0,1]];
data_out.ulen = [ulen,1];
data_out.ulabel = proj.ulab;
data_out.iax = iax;
data_out.iint = iint;
data_out.pax = pax;
data_out.p = p;
data_out.dax = 1:length(pax);   % until we have option to select display axes in place
if keep_pix
    data_out.s = s;
    data_out.e = e;
    data_out.npix = npix;
    data_out.urange = urange_pix;
    if ~pix_tmpfile; data_out.pix = pix; end
else
    data_out.s = s./npix;
    data_out.e = e./(npix.^2);
    no_pix = (npix==0);     % true where there are no pixels contributing to the bin
    data_out.s(no_pix)=NaN; % want signal to be NaN where there are no contributing pixels, not +/- Inf
    data_out.e(no_pix)=0;
end


% Save to file if requested
% ---------------------------
if save_to_file
    disp(['Writing cut to output file ',fopen(fout),'...'])
    try
        if ~pix_tmpfile
            mess = write_sqw (fout,main_header,header,detpar,data_out);
        else
            mess = write_sqw (fout,main_header,header,detpar,data_out,'-pix',pix.tmpfiles,pix.pos_npixstart,pix.pos_pixstart,'nochange');
            for ifile=1:length(pix.tmpfiles)   % delete the temporary files
                delete(pix.tmpfiles{ifile});
            end
        end
        fclose(fout);
        if ~isempty(mess)
            warning(['Error writing to file: ',mess])
        end
    catch   % catch just in case there is an error writing that is not caught - don;t want to waste all the cutting output
        if ~isempty(fopen(fout)); fclose(fout); end
        warning('Error writing to file: unknown cause')
    end
    disp(' ')
end


% Create output argument and/or file as necessary
% --------------------------------------------------
if nargout>0
    cut_out.main_header = main_header;
    cut_out.header = header;
    cut_out.detpar = detpar;
    cut_out.data   = data_out;
    if pix_to_cut
        cut = cut_out;          % should just pass the pointer
    else
        cut = sqw_to_dnd (cut_out);
    end
end

% ------------------------

disp(['Number of points in input file: ',num2str(npixtot)])
disp(['         Fraction of file read: ',num2str(100*npix_read/npixtot,'%8.4f'),' %   (=',num2str(npix_read),' points)'])
disp(['     Fraction of file retained: ',num2str(100*npix_retain/npixtot,'%8.4f'),' %   (=',num2str(npix_retain),' points)'])
disp(' ')
bigtoc('Total time in cut_sqw:')
disp('--------------------------------------------------------------------------------')
