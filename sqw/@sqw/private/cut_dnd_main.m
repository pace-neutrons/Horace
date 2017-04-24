function wout = cut_dnd_main (data_source, ndims, varargin)
% Takes cut from a dnd-type sqw object by integrating over plot axes.
%
%   >> w = cut_dnd_main (data_source, ndims, p1_bin, p2_bin...)
%
%   >> w = cut_dnd_main (..., '-save')   % Save cut to file (prompts for file)
%   >> w = cut_dnd_main (...,  filename) % save cut to named file
%
%   >> cut_dnd_main (...)                % save cut to file; no output workspace 
% 
% Input:
% ------
%   data_source     Data source: dnd object or filename of a file with
%                  sqw-type or dnd-type data (character string or cellarray
%                  with one character string)
%
%   p1_bin          Binning along first plot axis
%   p2_bin          Binning along second plot axis
%                           
%                   For each binning entry:
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: Step size pstep must be 0 or
%                              the current bin size (no other rebinning
%                              is permitted)
%           - [plo, phi]        Integration axis: range of integration.
%                              Those bin centres that lie inside this range 
%                              are included.
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centres.
%                              The step size pstep must be 0 or the current
%                              bin size (no other rebinning is permitted)
%
% Output:
% -------
%   w              Output data object (d0d, d1d or d2d depending on binning)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%

hor_log_level = config_store.instance.get_value('hor_config','log_level');

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

% Get binning information
pbin=varargin(1:end-length(opt));


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


% Checks on binning arguments
for i=1:numel(pbin)
    if ~(isempty(pbin{i}) || isnumeric(pbin{i}))
        error('Binning arguments must all be numeric')
    end
end
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
    fout = fopen (outfile, 'wb');
    if (fout < 0)
        error (['Cannot open output file ' outfile])
    end
end


% Get header information from the data source
% --------------------------------------------
if hor_log_level>=1, disp('--------------------------------------------------------------------------------'), end
if source_is_file  % data_source is a file
    if hor_log_level>=0, disp(['Taking cut from data in file ',data_source,'...']), end
    ld = sqw_formats_factory.instance().get_loader(data_source);
    data = ld.get_data('-nopix');
    %[mess,main_header,header,detpar,data]=get_sqw (data_source,'-nopix');
else
    if hor_log_level>=0, disp('Taking cut from dnd object...'), end
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

% in principle, these three lines are unnecessary, as we should have s, e =0 where npix=0 already
nopix = (npix==0);
s(nopix) = 0;   % must ensure zero so that can sum over integration range(s)
e(nopix) = 0;   % must ensure zero so that can sum over integration range(s)


% Check for the case when either data.s or data.e contain NaNs or Infs, but data.npix is not zero.
% and handle according to options settings.
[ignore_nan,ignore_inf]=get(hor_config,'ignore_nan','ignore_inf');
ignore_nan=logical(ignore_nan);
ignore_inf=logical(ignore_inf);

if ignore_nan || ignore_inf
    if ignore_nan && ignore_inf
        omit=~isfinite(s)|~isfinite(e);
    elseif ignore_nan
        omit=isnan(s)|isnan(e);
    elseif ignore_inf
        omit=isinf(s)|isinf(e);
    end
    s(omit)=0; e(omit)=0; npix(omit)=0;
end

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

% Catch pathological case of s or e being Inf and we request to ignore Inf
%(this can happen if sum several finite numbers that overflow to an infinite number).
%(There can be no case of a pathological NaN if requested NaNs to be ignored)
if ignore_inf
    omit=isinf(s)|isinf(e);
    s(omit)=0; e(omit)=0; npix(omit)=0;
end

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
    if hor_log_level>=0, disp(['Writing cut to output file ',fopen(fout),'...']), end
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
    if hor_log_level>=0, disp(' '), end
end


% Create output argument if requested
% -----------------------------------
if nargout~=0
    wout=sqw(w);
end
