function wout = cut_dnd (data_source, varargin)
% Take a cut from an dnd-type sqw object by integrating over one or more of the plot axes.
% 
% Syntax:
%  make cut:
%   >> w = cut (data_source, p1_bin, p2_bin...)     % cut plot axes, keeping existing integration ranges
%                                                   % (as many binning arguments as there are plot axes)
%   >> w = cut (..., '-save')       % Save cut to file (prompt for output file)
%   >> w = cut (...,  filename)     % save cut to named file
%
%   >> cut(...)                     % save cut to file without making output to workspace 
% 
% Input:
% ------
%   data_source     Data source: sqw file name or dnd-type data structure
%
%   p1_bin          Binning along first plot axis
%   p2_bin          Binning along second plot axis
%                           :
%                   for as many axes as there are plot axes. For each binning entry:
%               - [] or ''          Plot axis: use bin boundaries of input data
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%                                   If pstep=0 then use current bin size and synchronise
%                                  the output bin boundaries with the current boundaries. The overall range is
%                                  chosen to ensure that the range of the input data is contained within
%                                  the bin boundaries.
%               - [plo, phi]        Integration axis: range of integration - those bin centres that lie inside this range 
%                                  are included.
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%                                   If pstep=0 then use current bin size and synchronise
%                                  the output bin boundaries with the current boundaries. The overall range is
%                                  chosen to ensure that the range plo to phi is contained within
%                                  the bin boundaries.
%
% Output:
% -------
%   w              Output data object


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Parse input arguments
% ---------------------
% Determine if data source is sqw object or file
[data_source, args, source_is_file, sqw_type, ndims] = parse_data_source (data_source, varargin{:});
if sqw_type
    error('Logic problem in chain of cut methods. See T.G.Perring')
end

% Strip off final arguments that are character strings, and parcel the rest as binning arguments
% (the functions that use binning arguments are clever enough to handle incorrect number of arguments and types)
opt=cell(1,0);
if length(args)>=1 && ischar(args{end}) && size(args{end},1)==1
    opt{1}=args{end};
end

% Get binning information
pbin=args(1:end-length(opt));


% Do checks on input arguments
% ----------------------------
% Check consistency of optional arguments.
% (Do some checks for which there is reasonable default behaviour, but as cuts can take a long time, be cautious instead)
save_to_file=false;
outfile='';
if length(opt)==1
    if strncmpi(opt{1},'-save',max(length(opt{1}),2))
        save_to_file=true;
    else
        save_to_file=true;
        outfile=opt{1};
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
if numel(pbin)~=ndims
    error('Number of binning arguments must match dimension of dnd data being cut')
end

        
% Open output file if required
if save_to_file
    if isempty(outfile)
        outfile = putfile('*.d0d;*.d1d;*.d2d;*.d3d;*.d4d');
        if (isempty(outfile))
            error ('No output file name given')
        end
    end
    % Open output file now - don't want to discover there are problems after 30 seconds of calculation
    fout = fopen (outfile, 'W');
    if (fout < 0)
        error (['Cannot open output file ' outfile])
    end
end


% Get header information from the data source
% --------------------------------------------
if horace_info_level>=1, disp('--------------------------------------------------------------------------------'), end
if source_is_file  % data_source is a file
    if horace_info_level>=0, disp(['Taking cut from data in file ',data_source,'...']), end
    [main_header,header,detpar,data,mess]=get_sqw (data_source,'-nopix');
    if ~isempty(mess)
        error('Error reading data from file %s \n %s',data_source,mess)
    end
else
    if horace_info_level>=0, disp('Taking cut from dnd object...'), end
    data = data_source.data;
end


% Get plot and integration axis information, and which blocks of data to read from file/structure
% ------------------------------------------------------------------------------------------------

% order of pbin is display axes. Get the index array that reorders pbin into the order of plot axes
invdax=zeros(size(data.dax));
for i=1:numel(invdax)
    invdax(data.dax(i))=i;
end

% Get limits of data along the plot axes
[val, nbin] = data_bin_limits (data);

% Determine new plot and integration axes
[sub_iax, sub_iint, sub_pax, sub_p, noffset, nkeep, mess] = cut_dnd_calc_ubins (pbin(invdax), data.p, nbin);
if ~isempty(mess)
    error(mess)
end

% Create data structure for return object
% -------------------------------------------
data_out=data;

% update integration and plot axis info
iax=[data.iax,data.pax(sub_iax)];
iint=[data.iint,sub_iint];
[data_out.iax,ix]=sort(iax);
data_out.iint=iint(:,ix);
data_out.pax=data.pax(sub_pax);
data_out.p=sub_p;
dax=data.dax;
[dummy,data_out.dax]=sort(dax(sub_pax));    % dax(sub_pax) are those element of input pax that remain plot axes

% pick out data that will contribute to output object
array_section=cell(1,ndims);
for i=1:ndims
    array_section{i}=nkeep(1,i):nkeep(2,i);
end
s = data.s(array_section{:}).*data.npix(array_section{:});
e = data.e(array_section{:}).*(data.npix(array_section{:}).^2);
npix = data.npix(array_section{:});
nopix = (npix==0);
s(nopix) = 0;   % must ensure zero so that can sum over integration range(s)
e(nopix) = 0;   % must ensure zero so that can sum over integration range(s)

% also need to check for the (rare, and pathological) case when either
% data.s or data.e contain NaNs, but data.npix is not zero.
s_nans = isnan(s);
e_nans = isnan(e);
s(s_nans)=0; e(s_nans)=0; npix(s_nans)=0;
s(e_nans)=0; e(e_nans)=0; npix(e_nans)=0;

% sum over the integration axes. Perform the summation along the
% highest axis index - this allows succesive calls of routines that reduce dimension by one
% without the need for sophisticated book-keeping.
for i=numel(sub_iax):-1:1
    s=sum(s,sub_iax(i));
    e=sum(e,sub_iax(i));
    npix=sum(npix,sub_iax(i));
end
s = squeeze(s);     % need to remove singleton dimensions
e = squeeze(e);
npix = squeeze(npix);
if size(s,1)==1     % Can't squeeze away first dimension if size is 1. Must therefore enforce column vector. Usual Matlab stupidity.
    s=s'; e=e'; npix=npix';
end

% renormalise the data
s = s./npix;
e = e./(npix.^2);
nopix = (npix==0);  % true where there are no pixels contributing to the bin
s(nopix)=0;         % want signal to be NaN where there are no contributing pixels, not +/- Inf
e(nopix)=0;

% Catch pathological case of s or e being NaN
s_nans = isnan(s);
e_nans = isnan(e);
s(s_nans)=0; e(s_nans)=0; npix(s_nans)=0;
s(e_nans)=0; e(e_nans)=0; npix(e_nans)=0;

% insert results into output signal, error, npix arrays
matched_size=true(size(sub_pax));
sz=zeros(size(sub_pax));
for i=1:numel(sub_pax)
    sz(i)=numel(sub_p{i})-1;
    matched_size(i) = (size(s,i)==sz(i));
end
if all(matched_size)
    data_out.s=s;
    data_out.e=e;
    data_out.npix=npix;
else
    if length(sz)==1, sz=[sz,1]; end    % must add extra dimension to end if 1D dataset. Usual Matlab stupidity.
    data_out.s=zeros(sz); data_out.e=zeros(sz); data_out.npix=zeros(sz);
    array_section=cell(1,numel(sub_pax));
    for i=1:numel(sub_pax)
        array_section{i} = 1+noffset(i):size(s,i)+noffset(i);
    end
    data_out.s(array_section{:})=s;
    data_out.e(array_section{:})=e;
    data_out.npix(array_section{:})=npix;
end

% Make valid dnd-type sqw fields
[w,mess]=make_sqw(true,data_out);
if ~isempty(mess), error(mess), end


% Save to file if requested
% ---------------------------
if save_to_file
    if horace_info_level>=0, disp(['Writing cut to output file ',fopen(fout),'...']), end
    try
        mess = put_sqw (fout,w.main_header,w.header,w.detpar,w.data);
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
    wout=sqw(w);
end
