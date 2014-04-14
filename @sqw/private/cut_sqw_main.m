function wout = cut_sqw_main (data_source, ndims, varargin)
% Take a cut from an sqw object by integrating over one or more of the momentum and energy axes.
% 
%   >> w = cut_sqw_main (data_source, ndims, p1_bin, p2_bin...)     
%                                           % cut plot axes, keeping existing integration ranges
%                                           %(as many binning arguments as there are plot axes)
%
%   >> w = cut_sqw_main (data_source, ndims, proj, p1_bin, p2_bin, p3_bin, p4_bin)
%                                           % cut with new projection axes
%
%   >> w = cut_sqw_main (..., '-nopix')     % output cut is dnd structure
%
%   >> w = cut_sqw_main (..., '-save')      % Save cut to file (prompt for output file)
%   >> w = cut_sqw_main (...,  filename)    % save cut to named file
%
% For very large output, can avoid out-of-memory errors by writing file without
% making output to workspace:
%
%   >> cut(...)                     % save cut to file without making output to workspace 
% 
% Input:
% ------
%   data_source_in  Data source: sqw object or filename of a file with sqw-type data
%                  (character string or cellarray with one character string)
%
%   ndims           Number of dimensions of the sqw data
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
%                       proj.w          [1x3] Vector of third axis (r.l.u.) - only needed if third character of type is 'p'
%                               Will otherwise be ignored.
%                       proj.type       [1x3] Char. string defining normalisation:
%                           Each character indicates if u1, u2, u3 normalised as follows:
%                           - if 'a': unit length is one inverse Angstrom
%                           - if 'r': then if (h,k,l) in r.l.u., is normalised so max(abs(h,k,l))=1
%                           - if 'p': then normalised so that if the orthogonal set created from u and v is u1, u2, u3:
%                               |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                             i.e. the projections of u,v,w along u1,u2,u3 match the lengths of u1,u2,u3
%                           Default:
%                               'ppr'  if w not given
%                               'ppp'  if w is given
%                       proj.uoffset    Row or column vector of offset of origin of projection axes (r.l.u.)
%                       proj.lab        Short labels for u1,u2,u3,u4 as cell array (e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
%                         *OR*
%                       proj.lab1       Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%                       proj.lab2       Short label for u2 axis
%                       proj.lab3       Short label for u3 axis
%                       proj.lab4       Short label for u4 axis (e.g. 'E' or 'En')
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%               - [] or ''          Plot axis: use bin boundaries of input data
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%               - [plo, phi]        Integration axis: range of integration
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%
%   p4_bin          Binning along the energy axis:
%               - [] or ''          Plot axis: use bin boundaries of input data
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%                                  If pstep=0 then use bin size of the first spe file and synchronise
%                                  the output bin boundaries with those boundaries. The overall range is
%                                  chosen to ensure that the energy range of the input data is contained within
%                                  the bin boundaries.
%               - [plo, phi]        Integration axis: range of integration
%           	- [plo, pstep, phi]	Plot axis: minimum and maximum bin centres and step size;
%                                  If pstep=0 then use bin size of the first spe file and synchronise
%                                  the output bin boundaries with the reference boundaries. The overall range is
%                                  chosen to ensure that the energy range plo to phi is contained within
%                                  the bin boundaries.
%           
%
% Output:
% -------
%   w              Output data object:
%                     - sqw object with full pixel information
%                     - d0d,d1d...or d4d object if option '-nopix' given

% T.G.Perring   04/07/2007

% *** Currently only works if uoffset(4)=0 for input, output datasets

horace_info_level = get(hor_config,'horace_info_level');

if horace_info_level>=1
    bigtic
end

small = 1.0d-10;    % 'small' quantity for cautious dealing of borders, testing matricies are diagonal etc.


% Parse input arguments
% ---------------------
% Determine if data source is sqw object or file
if iscellstr(data_source)
    data_source=data_source{1};
    source_is_file=true;
elseif ischar(data_source)
    source_is_file=true;
elseif isa(data_source,'sqw')
    source_is_file=false;
else
    error('Logic problem in chain of cut methods. See T.G.Perring')
end

% Strip off final arguments that are character strings, and parcel the rest as binning arguments
% (the functions that use binning arguments are clever enough to handle incorrect number of arguments and types)
opt=cell(1,0);
if length(varargin)>=1 && ischar(varargin{end}) && size(varargin{end},1)==1
    opt{1}=varargin{end};
end
if length(varargin)>=2 && ischar(varargin{end-1}) && size(varargin{end-1},1)==1
    opt{2}=varargin{end-1};
end

% Get proj structure, if present, and binning information
if numel(varargin)>=1 && isstruct(varargin{1})
    proj_given=true;
    proj_in=varargin{1};
    pbin=varargin(2:end-length(opt));
else
    proj_given=false;
    pbin=varargin(1:end-length(opt));
end


% Do checks on input arguments
% ----------------------------
% Check consistency of optional arguments.
% (Do some checks for which there is reasonable default behaviour, but as cuts can take a long time, be cautious instead)
keep_pix=true;
save_to_file=false;
outfile='';
if length(opt)==1
    if strncmpi(opt{1},'-nopix',max(length(opt{1}),2))
        keep_pix=false;
    elseif strncmpi(opt{1},'-save',max(length(opt{1}),2))
        save_to_file=true;
    else
        save_to_file=true;
        outfile=opt{1};
    end
elseif length(opt)==2
    if (strncmpi(opt{1},'-nopix',max(length(opt{1}),2)) && strncmpi(opt{2},'-save',max(length(opt{2}),2))) ||...
       (strncmpi(opt{1},'-save',max(length(opt{1}),2)) && strncmpi(opt{2},'-nopix',max(length(opt{2}),2)))
        keep_pix=false;
        save_to_file=true;
    elseif strncmpi(opt{1},'-nopix',max(length(opt{1}),2))
        keep_pix=false;
        save_to_file=true;
        outfile=opt{2};        
    elseif strncmpi(opt{2},'-nopix',max(length(opt{2}),2))
        keep_pix=false;
        save_to_file=true;
        outfile=opt{1};
    else
        error('Check optional arguments: ''%s'' and ''%s''',opt{1},opt{2})
    end
end

if nargout==0 && ~save_to_file  % Check work needs to be done (*** might want to make this case prompt to save to file)
    error ('Neither output cut object nor output file requested - routine is not being asked to do anything')
end

if save_to_file && ~isempty(outfile)    % check file name makes reasonable sense if one has been supplied
    [out_path,out_name,out_ext]=fileparts(outfile);
    if length(out_ext)<=1    % no extension or just a dot
        error('Output filename ''%s'' has no extension - check optional arguments',outfile)
    end
end


% Checks on number of binning arguments
if ~proj_given          % must refer to plot axes (in the order of the display list)
    if numel(pbin)~=ndims
        error('Number of binning arguments must match the number of dimensions of the sqw data being cut')
    end
else                    % must refer to new projection axes
    if numel(pbin)~=4
        error('Must give binning arguments for all four dimensions if new projection axes')
    end
end
        

% Check the proj data structure is valid, if given
if ~proj_given
    proj = struct([]);
else
    [proj,mess] = proj_fill_fields(proj_in);
    if ~isempty(mess)
        error(mess)
    end
    % *** Currently the cut algorithm only works for energy offset=0
    if proj.uoffset(4)~=0
        error('Energy offset must be zero')
    end
end


% Open output file if required
if save_to_file
    if isempty(outfile)
        if keep_pix
            outfile = putfile('*.sqw');
        else
            outfile = putfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
        end
        if (isempty(outfile))
            error ('No output file name given')
        end
    end
    % Open output file now - don't want to discover there are problems after 30 seconds of calculation
    fout = fopen (outfile, 'w');
    if (fout < 0)
        error (['Cannot open output file ' outfile])
    end
    
end


% Get header information from the data source
% --------------------------------------------
if horace_info_level>0, disp('--------------------------------------------------------------------------------'), end
if source_is_file  % data_source is a file
    if horace_info_level>=0, disp(['Taking cut from data in file ',data_source,'...']), end
    [mess,main_header,header,detpar,data,position,npixtot,data_type]=get_sqw (data_source,'-nopix');

    if ~isempty(mess)
        error('Error reading data from file %s \n %s',data_source,mess)
    end
    if ~strcmpi(data_type,'a')
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error('Data file is not sqw file with pixel information - cannot take cut')
    end
else
    if horace_info_level>=0, disp('Taking cut from sqw object...'), end
    % for convenience, unpack the fields that themselves are major data structures
    %(no memory penalty as matlab just passes pointers)
    main_header = data_source.main_header;
    header = data_source.header;
    detpar = data_source.detpar;
    data   = data_source.data;
    npixtot= size(data.pix,2);
end


% Get some 'average' quantities for use in calculating transformations and bin boundaries
% -----------------------------------------------------------------------------------------
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines
header_ave=header_average(header);
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

if ~isempty(proj)
    [rlu_to_ustep, u_to_rlu] = rlu_to_ustep_matrix (alatt, angdeg, proj.u, proj.v, [1,1,1], proj.type, proj.w);
    uin_to_rlu = data.u_to_rlu(1:3,1:3);
    rot = inv(u_to_rlu)*uin_to_rlu;         % convert components from data input proj. axes to output proj. axes
    trans = inv(uin_to_rlu)*(proj.uoffset(1:3)-data.uoffset(1:3));  % offset between the origins of input and output proj. axes, in input proj. coords
else
    rot = eye(3);
    trans = [0;0;0];
end


% Get plot and integration axis information, and which blocks of data to read from file/structure
% ------------------------------------------------------------------------------------------------
% Construct bin boundaries cellarray for input data set, including integration axes as a single bin
% These will be the default bin inputs when computing the output bin boundary and integration ranges
pin=cell(1,4);
pin(data.pax)=data.p;   % works even if zero elements
pin(data.iax)=mat2cell(data.iint,2,ones(1,numel(data.iax)));

% If proj is not empty, then the input pbin are already correctly ordered as the projection axes, but if proj
% is empty, then the order is as the axes displayed in a plot
if isempty(proj)
    ptmp=pbin;          % input refers to display axes
    pbin=cell(1,4);     % Will reorder and insert integration ranges as required from input data
    % Get binning array from input display axes rebinning
    for i=1:numel(data.pax)
        j=data.dax(i);   % plot axis corresponding to ith binning argument
        pbin(data.pax(j))=ptmp(i);
    end
    % Can leave integration axis entries in pbin as empty, because in cut_sqw_calc_ubins this
    % will result in the default bins being used - which are currently set to the input integration ranges
end

% Get new plot bin boundaries, integration ranges etc., and the hypercuboid in the
% output data coordinate frame that encloses the output data volume
[iax, iint, pax, p, urange, mess] = cut_sqw_calc_ubins (data.urange, rot, trans, pbin, pin, en);
if ~isempty(mess)   % problem getting limits from the input
    if save_to_file; fclose(fout); end    % close the output file opened earlier
    error(mess)
end

% Get the start and end index of contiguous blocks of pixel information in the data
% *** should use optimised algorithm for cases when rot is diagonal ?
% *** should the border be bigger, to account for single <-> double rounding errors? (see value of small)
border = small*[-1,-1,-1,-1;1,1,1,1];   % put a small border around the range to ensure we don't miss any
                                        % pixels on the boundary because of rounding errors in get_nrange_rot_section
                                        
% Construct arrays of bin boundaries that include integration axes as axes with just one bin
% (Need to go through the following for the case when have data structure with less than four plot axes)
pin=cell(1,4);
pin(data.pax)=data.p;
pin(data.iax)=mat2cell(data.urange(:,data.iax),2,ones(1,length(data.iax)));
nbin_in=zeros(1,4);
for i=1:4
    nbin_in(i)=length(pin{i})-1;
end
% Reshape of data.npix in following line is necessary to insert singleton dimensions for integration axes
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
if ~isempty(proj)
    [rlu_to_ustep, u_to_rlu, ulen] = rlu_to_ustep_matrix (alatt, angdeg, proj.u, proj.v, ustep(1:3), proj.type, proj.w);
    rot_ustep = rlu_to_ustep*upix_to_rlu; % convert from pixel proj. axes to steps of output projection axes
    trans_bott_left = inv(upix_to_rlu)*(proj.uoffset(1:3)-upix_offset(1:3)+u_to_rlu*urange_offset(1,1:3)'); % offset between origin
    % of pixel proj. axes and the lower limit of hyper rectangle defined by range of data , expressed in pixel proj. coords
else
    u_to_rlu = data.u_to_rlu(1:3,1:3);
    ulen = data.ulen(1:3);
    ustep_to_rlu = zeros(3,3);
    for i=1:3
        ustep_to_rlu(:,i) = ustep(i)*u_to_rlu(:,i); % get step vector in r.l.u.
    end
    rlu_to_ustep = inv(ustep_to_rlu);
    rot_ustep = rlu_to_ustep*upix_to_rlu; % convert from pixel proj. axes to steps of output projection axes
    trans_bott_left = inv(upix_to_rlu)*(data.uoffset(1:3)-upix_offset(1:3)+u_to_rlu*urange_offset(1,1:3)'); % offset between origin
    % of pixel proj. axes and the lower limit of hyper rectangle defined by range of data , expressed in pixel proj. coords
end
ebin=ustep(4);                  % plays role of rot_ustep for energy
trans_elo = urange_offset(1,4); % plays role of trans_bott_left for energy
% set flag to indicate if buffering to temporary files is permitted
if nargout==0   % can buffer only if no output cut object
   pix_tmpfile_ok = true;
else
   pix_tmpfile_ok = false;
end


% Get accumulated signal
% -----------------------
% read data and accumulate signal and error
if source_is_file
    
    fid=fopen(data_source,'r');
    if fid<0
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error(['Unable to open file ',data_source])
    end
    status=fseek(fid,position.pix,'bof');    % Move directly to location of start of pixel data block
    if status<0;
        fclose(fid);
        if save_to_file; fclose(fout); end    % close the output file opened earlier
        error(['Error finding location of pixel data in file ',data_source]);
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
data_out.filename = data.filename;
data_out.filepath = data.filepath;
data_out.title = data.title;
data_out.alatt = alatt;
data_out.angdeg = angdeg;
if ~isempty(proj)
    data_out.uoffset = proj.uoffset;
else
    data_out.uoffset = data.uoffset;
end
data_out.u_to_rlu = [[u_to_rlu,[0;0;0]];[0,0,0,1]];
data_out.ulen = [ulen,1];
if ~isempty(proj)
    data_out.ulabel = proj.lab;
else
    data_out.ulabel = data.ulabel;
end
data_out.iax = iax;
data_out.iint = iint;
data_out.pax = pax;
data_out.p = p;
if ~isempty(proj)
    data_out.dax = 1:length(pax);   % until we have option to select display axes in place
else
    data_out.dax = zeros(1,length(pax));
    plotaxis = data.pax(data.dax);   % plot axes in the input data set in order x-axis, y-axis, ...
    j=1;
    for i=1:length(plotaxis)
        idax = find(plotaxis(i)==pax);
        if ~isempty(idax)   % must be in the list if a plot axis
            data_out.dax(j)=idax;
            j=j+1;
        end
    end
end
data_out.s = s./npix;
data_out.e = e./(npix.^2);
data_out.npix = npix;
no_pix = (npix==0);     % true where there are no pixels contributing to the bin
data_out.s(no_pix)=0;   % want signal to be NaN where there are no contributing pixels, not +/- Inf
data_out.e(no_pix)=0;

if keep_pix
    data_out.urange = urange_pix;
    if ~pix_tmpfile; data_out.pix = pix; end
end

% Collect fields to make those for a valid sqw object
if keep_pix
    w.main_header=main_header;
    w.header=header;
    w.detpar=detpar;
    w.data=data_out; % will be missing the field 'pix' if pix_tmpfile_ok=true
else
    [w,mess]=make_sqw(true,data_out);   % make dnd-type sqw structure
    if ~isempty(mess), error(mess), end
end


% Save to file if requested
% ---------------------------
if save_to_file
    if horace_info_level>=0, disp(['Writing cut to output file ',fopen(fout),'...']), end
    try
        if ~pix_tmpfile
            mess = put_sqw (fout,w.main_header,w.header,w.detpar,w.data);
        else
            mess = put_sqw (fout,w.main_header,w.header,w.detpar,w.data,'-pix',pix.tmpfiles,pix.pos_npixstart,pix.pos_pixstart,'nochange');
            for ifile=1:length(pix.tmpfiles)   % delete the temporary files
                delete(pix.tmpfiles{ifile});
            end
        end
        fclose(fout);
        if ~isempty(mess)
            warning(['Error writing to file: ',mess])
        end
    catch   % catch just in case there is an error writing that is not caught - don't want to waste all the cutting output
        if ~isempty(fopen(fout)); fclose(fout); end
        warning('Error writing to file: unknown cause')
    end
    if horace_info_level>=0, disp(' '), end
end


% Create output argument if requested
% -----------------------------------
if nargout~=0
    if keep_pix
        wout=sqw(w);
    else
        wout=dnd(sqw(w));
    end
end

% ------------------------

if horace_info_level>=1
    disp(['Number of points in input file: ',num2str(npixtot)])
    disp(['         Fraction of file read: ',num2str(100*npix_read/npixtot,'%8.4f'),' %   (=',num2str(npix_read),' points)'])
    disp(['     Fraction of file retained: ',num2str(100*npix_retain/npixtot,'%8.4f'),' %   (=',num2str(npix_retain),' points)'])
    disp(' ')
    bigtoc('Total time in cut_sqw:')
    disp('--------------------------------------------------------------------------------')
end
